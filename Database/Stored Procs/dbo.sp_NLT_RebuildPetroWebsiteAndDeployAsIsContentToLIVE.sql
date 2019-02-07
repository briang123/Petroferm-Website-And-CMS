
create proc sp_NLT_RebuildPetroWebsiteAndDeployAsIsContentToLIVE
	@UserID int = 1
as
begin
	-- rebuild the petroferm and deploy the default content "as-is"
	exec sp_NLT_BuildPetrofermFromScratchOnlyPetroData 1, 1
	exec sp__UpdateJobStatus 1, @UserID, 'PENDING DEPLOYMENT'
	exec sp_UTIL_DeployCMSContent @UserID, 1
end