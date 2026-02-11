unit sortbase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TSortCompareFuncContext = function(Item1, Item2, Context: Pointer): Integer;
  TSortCompareFuncNoContext = function(Item1, Item2: Pointer): Integer;
  // Alias for compatibility if needed, though usually function pointer types match by signature
  TListSortComparer_NoContext = TSortCompareFuncNoContext;

  PSortingAlgorithm = ^TSortingAlgorithm;
  TSortingAlgorithm = record
    ItemListSorter_ContextComparer: procedure(Base: Pointer; Count: Integer; ElementSize: Integer; Compare: TSortCompareFuncContext; Context: Pointer);
    PtrListSorter_NoContextComparer: procedure(Base: Pointer; Count: Integer; Compare: TSortCompareFuncNoContext);
  end;

var
  DefaultSortingAlgorithm: PSortingAlgorithm;

implementation

type
  TInternalSorting = class
    class procedure QuickSortContext(Base: Pointer; L, R: Integer; ElementSize: Integer; Compare: TSortCompareFuncContext; Context: Pointer);
    class procedure QuickSortNoContext(Base: Pointer; L, R: Integer; Compare: TSortCompareFuncNoContext);
  end;

var
  GAlgorithm: TSortingAlgorithm;

class procedure TInternalSorting.QuickSortContext(Base: Pointer; L, R: Integer; ElementSize: Integer; Compare: TSortCompareFuncContext; Context: Pointer);
var
  I, J: Integer;
  P, T: Pointer;
  PI, PJ: Pointer;
begin
  if L < R then
  begin
    GetMem(T, ElementSize);
    try
      I := L;
      J := R;
      // Pivot
      P := Base + ((L + R) div 2) * ElementSize;
      repeat
        while Compare(Base + I * ElementSize, P, Context) < 0 do Inc(I);
        while Compare(Base + J * ElementSize, P, Context) > 0 do Dec(J);
        if I <= J then
        begin
          PI := Base + I * ElementSize;
          PJ := Base + J * ElementSize;
          // Swap content
          Move(PI^, T^, ElementSize);
          Move(PJ^, PI^, ElementSize);
          Move(T^, PJ^, ElementSize);
          
          // If Pivot was swapped (it's pointing into the array), update it
          // Note: P is a pointer calculated from Base, but if we move data, P still points to the same memory address, 
          // but the data at that address has changed. 
          // Wait, QuickSort usually picks the value of the pivot.
          // Since we are dealing with generic data, we should copy the pivot value to a temp buffer if we want to be safe,
          // OR we just accept that we are comparing against the value at the pivot position.
          // BUT, if we swap the pivot position, the pivot value changes.
          // Standard implementation copies the pivot value.
          // Let's copy pivot value to T and use T for comparison.
          
          Inc(I);
          Dec(J);
        end;
      until I > J;
      
      // Recursive calls
      if L < J then QuickSortContext(Base, L, J, ElementSize, Compare, Context);
      if I < R then QuickSortContext(Base, I, R, ElementSize, Compare, Context);
    finally
      FreeMem(T);
    end;
  end;
end;

// Correct implementation of QuickSortContext using Pivot Copy
procedure QuickSortContext_Impl(Base: Pointer; L, R: Integer; ElementSize: Integer; Compare: TSortCompareFuncContext; Context: Pointer);
var
  I, J: Integer;
  Pivot, Temp: Pointer;
begin
  if L >= R then Exit;
  
  GetMem(Pivot, ElementSize);
  GetMem(Temp, ElementSize);
  try
    I := L;
    J := R;
    // Copy Pivot Value
    Move((Base + ((L + R) div 2) * ElementSize)^, Pivot^, ElementSize);
    
    repeat
      while Compare(Base + I * ElementSize, Pivot, Context) < 0 do Inc(I);
      while Compare(Base + J * ElementSize, Pivot, Context) > 0 do Dec(J);
      if I <= J then
      begin
        // Swap
        Move((Base + I * ElementSize)^, Temp^, ElementSize);
        Move((Base + J * ElementSize)^, (Base + I * ElementSize)^, ElementSize);
        Move(Temp^, (Base + J * ElementSize)^, ElementSize);
        Inc(I);
        Dec(J);
      end;
    until I > J;
    
    if L < J then QuickSortContext_Impl(Base, L, J, ElementSize, Compare, Context);
    if I < R then QuickSortContext_Impl(Base, I, R, ElementSize, Compare, Context);
  finally
    FreeMem(Pivot);
    FreeMem(Temp);
  end;
end;


class procedure TInternalSorting.QuickSortNoContext(Base: Pointer; L, R: Integer; Compare: TSortCompareFuncNoContext);
type
  PPointer = ^Pointer;
var
  I, J: Integer;
  P, T: Pointer;
  Arr: PPointer;
begin
  Arr := PPointer(Base);
  if L < R then
  begin
    I := L;
    J := R;
    P := Arr[(L + R) div 2];
    repeat
      while Compare(Arr[I], P) < 0 do Inc(I);
      while Compare(Arr[J], P) > 0 do Dec(J);
      if I <= J then
      begin
        T := Arr[I];
        Arr[I] := Arr[J];
        Arr[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSortNoContext(Base, L, J, Compare);
    if I < R then QuickSortNoContext(Base, I, R, Compare);
  end;
end;

procedure ItemListSorter_ContextComparer_Impl(Base: Pointer; Count: Integer; ElementSize: Integer; Compare: TSortCompareFuncContext; Context: Pointer);
begin
  if Count > 1 then
    QuickSortContext_Impl(Base, 0, Count - 1, ElementSize, Compare, Context);
end;

procedure PtrListSorter_NoContextComparer_Impl(Base: Pointer; Count: Integer; Compare: TSortCompareFuncNoContext);
begin
  if Count > 1 then
    TInternalSorting.QuickSortNoContext(Base, 0, Count - 1, Compare);
end;

initialization
  GAlgorithm.ItemListSorter_ContextComparer := @ItemListSorter_ContextComparer_Impl;
  GAlgorithm.PtrListSorter_NoContextComparer := @PtrListSorter_NoContextComparer_Impl;
  DefaultSortingAlgorithm := @GAlgorithm;

end.
