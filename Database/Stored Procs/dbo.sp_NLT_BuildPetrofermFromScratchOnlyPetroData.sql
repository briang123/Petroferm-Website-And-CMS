

-- Batch submitted through debugger: Alter dbo.sp_NLT_BuildPetrofermFromScratchOnlyPetroData_1|9|0|edb51f04-b615-4921-b2da-a95d41272cdfMSSQL__/_localdb__ProjectsV13/Petroferm/True/SqlProcedure/Alter dbo.sp_NLT_BuildPetrofermFromScratchOnlyPetroData_1.sql

CREATE PROCEDURE sp_NLT_BuildPetrofermFromScratchOnlyPetroData @are_you_sure BIT = 0
	,@uid INT = 0
AS
BEGIN
	DECLARE @errorcode INT
		,@jid INT

	SELECT @errorcode = @@error

	IF (@are_you_sure = 1)
	BEGIN
		BEGIN TRANSACTION

		PRINT 'STEP 1: drop all LIVE tables'

		EXEC sp_UTIL_BuildPetrofermLiveTables 1

		SELECT @errorcode = @@error

		PRINT 'STEP 2: re-create LIVE tables'

		EXEC sp_UTIL_BuildPetrofermLiveTables

		SELECT @errorcode = @@error

		IF (@errorcode = 0)
		BEGIN
			PRINT 'STEP 3: truncate all data from non-live tables'

			EXEC sp_NLT_TruncateDataFromNonLiveTables 1

			SELECT @errorcode = @@error
		END

		IF (@errorcode = 0)
		BEGIN
			PRINT 'STEP 4: create deployment to manage the deployment of these modifications'

			INSERT INTO tblDeploymentJobs (
				JobName
				,JobDescription
				,ReviewBy
				,ApprovedBy
				,DeploymentDate
				,DeployedBy
				,WorkflowStatus
				)
			VALUES (
				'REBUILD PETROFERM FROM SCRATCH'
				,'Drop live tables, truncate all staging data (from non-lookup tables), and reload all the default Petroferm content so that business units can be added.'
				,0
				,0
				,dbo.fn__GetDateOnly(getdate())
				,0
				,'WORKING'
				)

			-- get the job id associated with this deployment
			SELECT @jid = @@identity

			DECLARE @userName VARCHAR(150)

			SELECT @userName = FirstName + ' ' + LastName
			FROM tblAppUser
			WHERE AppUserId = @uid

			INSERT INTO tblWorkflowAudit_U (
				DeploymentJobId
				,WorkflowStatus
				,StatusChangedBy
				,StatusChangeDate
				,LastModifiedBy
				)
			VALUES (
				@jid
				,'WORKING'
				,@userName
				,getdate()
				,@uid
				)
		END

		IF (@errorcode = 0)
		BEGIN
			PRINT 'STEP 5: rebuild the Petroferm default content (build required pages)'

			DECLARE @retval INT
				,@busName VARCHAR(300)
				,@isPetro BIT
				,@busId INT
				,@logoId INT

			EXEC @retval = sp__AddBusinessUnit @BusName = 'Petroferm Inc.'
				,@DocAuth = 0
				,@PublishDate = NULL
				,@ExpireDate = NULL
				,@WorkflowStatus = 'WORKING'
				,@UserId = @uid
				,@ActiveFlag = 1
				,@MarkedForDeletion = 0
				,@LogoImagePath = 'web/files/images/logos/PetrofermLogo.png'
				,@ExistingLogoID = 0
				,@JobId = @jid
				,@IsPetro = 1
				,@LogoID = @logoId OUTPUT
				,@BusUnitID = @busId OUTPUT

			SELECT @errorcode = @@error

			
		END

		PRINT 'STEP 6: Update the Petroferm TableDefs table'

		EXEC sp_UTIL_UpdatePetrofermTableDefs

		IF (@errorcode <> 0)
		BEGIN
			PRINT 'An error occurred while rebuilding the Petroferm website from scratch. All operations will rollback to the original state.'
			ROLLBACK TRANSACTION
			RETURN 0
		END
		
			PRINT 'The Petroferm website was successfully rebuilt from scratch.'
			COMMIT TRANSACTION
			RETURN 1

	END
	ELSE
	BEGIN
		PRINT 'You are not sure you want to build the Petroferm website from scratch, so the process was aborted.'
	END
END