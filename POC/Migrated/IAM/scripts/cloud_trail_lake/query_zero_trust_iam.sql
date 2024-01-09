# https://github.com/tradichel/SecurityMetricsAutomation
# IAM/scripts/cloud_trail_lake
# author: @tradichel @2ndsightlab
##############################################################

SELECT DISTINCT eventSource, eventName FROM [Event Data Store ID Here] WHERE  userIdentity.sessioncontext.sessionissuer.username = '[username here]'
order by eventSource

