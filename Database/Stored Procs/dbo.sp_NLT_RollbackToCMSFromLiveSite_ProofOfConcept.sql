
CREATE proc sp_NLT_RollbackToCMSFromLiveSite_ProofOfConcept
	@are_you_sure bit = 0
as
begin

if (@are_you_sure = 1)
begin

	exec sp_NLT_BuildPetrofermFromScratchOnlyPetroData 1, 1
	
	-- query off of our live tables so we see what we are going to revert back from
	select 'NEXT 2 TABLES ARE THE CMS, THEN LIVE PAGE TABLE'
	select * from tblpage
	select * from tblpage_live
	
	select 'NEXT 2 TABLES ARE THE CMS, THEN LIVE PAGE MOD RELN TABLE'
	select * from tblPageModuleReln
	select * from tblPageModuleReln_live
	
	-- update our default petroferm content to be prepped for deployment
	exec sp__UpdateJobStatus 1, 1, 'PENDING DEPLOYMENT'
	
	-- deploy the petroferm content pages to live site
	exec sp_UTIL_DeployCMSContent 1, 1
	
	-- let's create a new job so we can make changes
	--create new job (id = 2) -- wf status = working
	insert into tblDeploymentJobs (jobname,jobdescription,reviewby,approvedby,deploymentdate,deployedby,workflowstatus,lastmodifieddate,lastmodifiedby,activeflag)
	values ('test rollback','test rollback',1,1,getdate(),1,'WORKING',getdate(),1,1)
	
	-- make a couple changes, then we'll change our mind
	UPDATE TBLPAGEMODULERELN SET SHOWTITLE = 0, DEPLOYMENTJOBID = 2, WorkflowStatus = 'WORKING' 
	UPDATE tblPage set PageTitle = 'WRONG CHANGE', DeploymentJobId = 2, WorkflowStatus = 'WORKING' where PageId = 2
	
	select 'NEXT 2 TABLES ARE THE CMS PAGE AND MOD RELN TABLE AFTER UPDATING THEM AND BEFORE ROLLBACK'
	-- we review the cms table and notice that our changes are reverted back to what we had before we created this job
	select pageid,pagetitle,workflowstatus,deploymentjobid from tblpage
	select * from tblPageModuleReln
	
	-- we perform our rollback for job id = 2
	exec sp_UTIL_UpdateCMSContentFromLiveSiteByJobID 1, 2
	
	select 'NEXT 2 TABLES ARE THE CMS PAGE AND MOD RELN TABLE AFTER ROLLBACK'
	-- we review the cms table and notice that our changes are reverted back to what we had before we created this job
	select pageid,pagetitle,workflowstatus,deploymentjobid from tblpage
	select * from tblPageModuleReln
	
	/* miscellaneous helper scripts */
	--update tblPageModuleReln set workflowstatus = 'WORKING', showtitle = 0, deploymentjobid = 2 where pageid = 3
	--select pageid,pagetitle,workflowstatus,deploymentjobid from tblpage_live
	--select * from tblDeploymentQueue_U
	--select * from tblDeploymentQueueHistory_U
	--select * from tblDeploymentSqlLog_U
	--select * from tblDeploymentJobs
	--truncate table tbldeploymentjobs
	--select * from tblPetrofermTableDefs_U
	
end

end