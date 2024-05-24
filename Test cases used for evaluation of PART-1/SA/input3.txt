program ArrayAverage;
var
  grade : char ;
  isready : boolean ;
  numbers : array [1..10] of Integer ;
  number, i, sum : Integer;
  maxValue : real;
  // the programs starts here
begin
  write("Enter a number:");
  read(number);
  while number <> 0 do
  begin
    if number > 0 then
    begin
      count:=count+1;
    end
    else
    begin
     count :=count;
    end;
    number := number - (number / 10) * 10;
    number := number %  10;
  end;
  for i := 2 to 10 do
  begin
    if numbers[i] <= maxValue then
    begin
      maxValue := numbers[i] + 10;
    end;
  end;
  average := sum / 5;
  write(sum, maxValue);
  // the program ends here
end.
