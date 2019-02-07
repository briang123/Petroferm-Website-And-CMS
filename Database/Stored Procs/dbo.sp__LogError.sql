








CREATE       PROC sp__LogError(
	@SourceFileName 	varchar(255) = null,
	@SourceMethodName 	varchar(255) = null,
	@Message		text = null,
	@StackTrace		text = null,
	@Source			text = null,
	@UserName 		varchar(100) = null,
	@ErrorID		int OUTPUT
)
AS
BEGIN
	IF ( dbo.fn__TableExists('tblError') > 0 )
	BEGIN

	
	
		INSERT INTO tblError (	
				SourceFileName,
				SourceMethodName,
				Message,
				StackTrace,
				Source, 
				UserName)
		VALUES (	@SourceFileName,
				@SourceMethodName,
				@Message,
				@StackTrace,
				@Source, 
				@UserName)

		IF ( @@ERROR = 0 )
		BEGIN
			SELECT @ErrorID = @@IDENTITY
			RETURN 1
		END
		ELSE
		BEGIN
			SELECT @ErrorID = 0
			RETURN 0
		
		END
	END
	ELSE
		PRINT 'A table which is required to perform this action is missing.'
		RETURN 0
	END