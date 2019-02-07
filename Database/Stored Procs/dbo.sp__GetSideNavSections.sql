




--sp__GetSideNavSections
CREATE         proc sp__GetSideNavSections
		@UserSelect int = 0
as

/*
created by: Kelly Roe
created on: 12/13/2006
purpose:
	Return a list of side nav sections from the lookup table

history:
	Kelly Roe    (12/13/2006) - created initial procedure
	Kelly Roe    (12/13/2006) - added arg to see whether to exclude links if a 
				    user is selecting from this list for adding a new 
				    page into the side nav
*/


begin

	if (@UserSelect = 0)
	begin
		SELECT 	SectionID,
			SectionName,
			SectionOrder,
			ActiveFlag 
		FROM 	tblSideNavSection_LKP
		where  	ActiveFlag = 1
		order by SectionOrder, SectionName
	end
	else
	begin
		SELECT 	SectionID,
			SectionName,
			SectionOrder,
			ActiveFlag 
		FROM 	tblSideNavSection_LKP
		where  	ActiveFlag = 1
		and	SectionID <> 5 -- exclude the information/sample requests
		order by SectionOrder, SectionName


	end

end