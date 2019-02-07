

CREATE  proc sp_NLT_GetDefaultFacilityList
as
begin

	select 	u.username, 
		f.facilityName
	from 	tblfacilityusers fu, 
		tblusers u, 
		tblfacility f 
	where 	u.userid = fu.userid
	and	fu.facilityId = f.facilityid
	and 	fu.defaultfacility = 1
end