program MaxValueArray;
var
  numbers: array[1..10] of Integer;
  i, j, maxValue: Integer;
begin
  write("Enter 10 integer values:");
  for i := 1 to 10 do
  begin
    read(numbers[i]);
  end;
  j := 1; 
  maxValue := numbers[1];
  for i := j+2 to j+5 do
  begin
    if numbers[i] <> maxValue then
    begin
      maxValue := numbers[i];
    end;
  end;
 
  write("The value is ");  
  write(maxValue);
end.
