

CREATE  proc sp_NLT_PageModuleDeploymentQuickFix
	@jobid int,
	@pm_relnId int = 0,
	@contentid int = 0
as
begin

	if (@pm_relnid=0 and @contentid=0)
	begin
		update tblpagemodulereln 
		set deploymentjobid = @jobid 
		where pagemodulerelnid in (
			select pagemodulerelnid 
			from tblpagemodulereln 
			where workflowstatus <> 'LIVE')
		
		
		update tblcontentmodule 
		set deploymentjobid = @jobid 
		where contentid in (
			select contentid
			from tblcontentmodule
			where workflowstatus <> 'LIVE')	
	end
	else
	begin
		update tblpagemodulereln 
		set deploymentjobid = @jobid 
		where pagemodulerelnid = @pm_relnid
	
		update tblcontentmodule 
		set deploymentjobid = @jobid 
		where contentid = @contentid
	
	end
end