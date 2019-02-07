

CREATE FUNCTION fn__GetDateOnly (
	@date datetime
)
RETURNS datetime
AS
BEGIN
	return convert(datetime,convert(varchar(25),@date,101) + ' 12:00:00AM')
END