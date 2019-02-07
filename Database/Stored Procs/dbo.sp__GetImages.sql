



CREATE       PROC sp__GetImages
		@ExcludeSpacerGif bit = 1
AS
BEGIN

	SELECT 	i.ImageID,
		i.ImagePath,
		replace(lower(i.ImagePath), 'web/files/images/','') As FmtImagePath,
		i.Alt,
		i.Width,
		i.Height		
	FROM 	tblImage i
	WHERE 	i.ActiveFlag = 1 
	and @ExcludeSpacerGif = 1
	and lower(i.ImagePath) not like '%spacer.gif%'
	ORDER BY i.ImagePath

END