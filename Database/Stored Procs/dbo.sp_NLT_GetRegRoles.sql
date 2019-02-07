

create proc sp_NLT_GetRegRoles
as
begin
	select reg.FullName, r.rolename
	from 	aspnet_usersinroles mr, 
		aspnet_roles r,
		tblRegistrant reg
	where r.roleid=mr.roleid
	and mr.userid=reg.userid
	order by reg.FullName
end