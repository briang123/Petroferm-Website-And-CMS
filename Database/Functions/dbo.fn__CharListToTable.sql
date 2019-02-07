



CREATE FUNCTION fn__CharListToTable (
	@list      ntext,
	@delimiter nchar(1) = N','
)
RETURNS @tbl TABLE 
	(	listpos int IDENTITY(1, 1) NOT NULL,
        	str     varchar(4000),
                nstr    nvarchar(2000)) as

begin

--- Usage Syntax: select * from fn__CharListToTable('1,2,3',',')

declare @pos int,
      	@textpos  int,
      	@chunklen smallint,
      	@tmpstr   nvarchar(4000),
      	@leftover nvarchar(4000),
      	@tmpval   nvarchar(4000)

     	select @textpos = 1
      	select @leftover = ''
      	while @textpos <= datalength(@list) / 2
      	begin
		select @chunklen = 4000 - datalength(@leftover) / 2
         	select @tmpstr = @leftover + substring(@list, @textpos, @chunklen)
         	select @textpos = @textpos + @chunklen
	        select @pos = charindex(@delimiter, @tmpstr)

         	while @pos > 0
         	begin
            		select @tmpval = ltrim(rtrim(left(@tmpstr, @pos - 1)))
            		insert @tbl (str, nstr) VALUES(@tmpval, @tmpval)
            		select @tmpstr = substring(@tmpstr, @pos + 1, len(@tmpstr))
            		select @pos = charindex(@delimiter, @tmpstr)
         	end

         	select @leftover = @tmpstr
      	end

     	insert @tbl(str, nstr) VALUES (ltrim(rtrim(@leftover)), ltrim(rtrim(@leftover)))
   	return 
end