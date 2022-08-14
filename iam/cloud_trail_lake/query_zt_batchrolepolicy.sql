SELECT DISTINCT eventSource, eventName FROM [Event Data Store ID Here] WHERE  userIdentity.sessioncontext.sessionissuer.username = '[username here]'
order by eventSource

