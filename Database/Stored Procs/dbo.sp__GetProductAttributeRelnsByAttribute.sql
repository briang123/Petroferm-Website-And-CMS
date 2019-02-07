








--sp__GetProductAttributeRelnsByAttribute 1
CREATE     PROC sp__GetProductAttributeRelnsByAttribute
	@AttribID int = null
AS
BEGIN

/*
created by: Kelly Roe
created on: 12/02/2006

purpose:
	Get a list of DISTINCT product attribute values by attribute

parameters:
	@AttribID - Attrib Id 

history:
	Kelly Roe    (12/02/2006) - created initial procedure
*/

if (@AttribID is null or @AttribID = 0)
begin
	print 'A attribute is required.'
	return 0
end
else
begin

	if (dbo.fn__TableExists('tblProductAttributeReln') > 0) 
	begin

		select distinct l.AttribValue
		from	tblProductAttributeReln l
		where	l.ActiveFlag = 1
		and	l.AttribTypeID = @AttribID
		order by l.AttribValue asc
	end
	else
	begin
		print 'You are missing some tables'
		return 0
	end
	
end

END