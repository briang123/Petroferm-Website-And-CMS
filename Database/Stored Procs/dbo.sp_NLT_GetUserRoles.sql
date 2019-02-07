
create proc sp_NLT_GetUserRoles
as
begin
	select mu.username,r.rolename
	from aspnet_membership m, aspnet_users mu, aspnet_usersinroles mr, aspnet_roles r
	where r.roleid=mr.roleid
	and mr.userid=m.userid
	and m.userid=mu.userid
	order by mu.username
end