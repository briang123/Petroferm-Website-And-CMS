
CREATE   FUNCTION fn__FormatDate (
	@date 		datetime,
	@format_string	varchar(100)
)
RETURNS varchar(100)
AS
 -- Any format string (mm, m, dd, d, yyyy, yy, hh, h, nn, n, ss, s)
BEGIN
	DECLARE @date_string as varchar(100)
	SET @date_string = @format_string
	-- handle year - yyyy
	SET @date_string = REPLACE(@date_string, 'yyyy', CAST(YEAR(@date) AS char(4)))
	-- handle year - yy
	SET @date_string = REPLACE(@date_string, 'yy', RIGHT(CAST(YEAR(@date) AS char(4)), 2))
	-- handle milliseconds - ms
	-- handle before months and seconds not to confuse a single m or s
	SET @date_string = REPLACE(@date_string, 'ms', REPLICATE('0', 3 - LEN(CAST(DATEPART(ms, @date) AS varchar(3)))) + CAST(DATEPART(ms, @date) AS varchar(3)))
	-- handle month - mm - leading zero, m - no leading zero
	SET @date_string = REPLACE(@date_string, 'mm', REPLICATE('0', 2 - LEN(CAST(MONTH(@date) AS varchar(2)))) + CAST(MONTH(@date) AS varchar(2)))
	SET @date_string = REPLACE(@date_string, 'm', CAST(MONTH(@date) AS varchar(2)))
	-- handle day - dd - leading zero, d - no leading zero
	SET @date_string = REPLACE(@date_string, 'dd', REPLICATE('0', 2 - LEN(CAST(DAY(@date) AS varchar(2)))) + CAST(DAY(@date) AS varchar(2)))
	SET @date_string = REPLACE(@date_string, 'd', CAST(DAY(@date) AS varchar(2)))
	
	-- handle hour - hh - leading zero, h - no leading zero
	SET @date_string = REPLACE(@date_string, 'hh', REPLICATE('0', 2 - LEN(CAST(DATEPART(hh, @date) AS varchar(2)))) + CAST(DATEPART(hh, @date) AS varchar(2)))
	SET @date_string = REPLACE(@date_string, 'h', CAST(DATEPART(hh, @date) AS varchar(2)))
	-- handle minute - nn - leading zero, n - no leading zero
	SET @date_string = REPLACE(@date_string, 'nn', REPLICATE('0', 2 - LEN(CAST(DATEPART(n, @date) AS varchar(2)))) + CAST(DATEPART(n, @date) AS varchar(2)))
	SET @date_string = REPLACE(@date_string, 'n', CAST(DATEPART(n, @date) AS varchar(2)))
	-- handle second - ss - leading zero, s - no leading zero
	SET @date_string = REPLACE(@date_string, 'ss', REPLICATE('0', 2 - LEN(CAST(DATEPART(ss, @date) AS varchar(2)))) + CAST(DATEPART(ss, @date) AS varchar(2)))
	SET @date_string = REPLACE(@date_string, 's', CAST(DATEPART(ss, @date) AS varchar(2)))
	
	RETURN @date_string
END