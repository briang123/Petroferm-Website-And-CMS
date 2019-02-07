

CREATE  PROC sp_NLT_FindProcsContaining
	@search varchar(100) = ''
as
begin
	set @search = '%' + @search + '%'
	select routine_name, routine_definition
	from information_schema.routines
	where routine_definition like @search
	order by routine_name
end