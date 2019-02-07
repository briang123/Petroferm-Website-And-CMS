
create proc sp_NLT_GetStoredProcList
as
begin
select distinct(specific_name) from tblPetrofermSqlDefs_U
end