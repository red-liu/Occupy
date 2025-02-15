
sink("Bayesian/NMixtureRagged.jags")

cat("
    model {
    
  for (i in 1:Birds){
    for (j in 1:Plants){
      #Process Model
      log(lambda[i,j])<-alpha[i] + beta[i] * traitmatch[i,j]

      #True state model  
      N[i,j] ~ dpois(lambda[i,j])
      }
    }

    #Observation Model
    for (i in 1:Nobs){
      Y[i] ~ dbin(detect[Bird[i]],N[Bird[i],Plant[i]]) 
      
      #Fit discrepancy statistics
      eval[i]<-detect[Bird[i]]*N[Bird[i],Plant[i]]
      E[i]<-pow((Y[i]-eval[i]),2)/(eval[i]+0.5)

      y.new[i]~dbin(detect[Bird[i]],N[Bird[i],Plant[i]])
      E.new[i]<-pow((y.new[i]-eval[i]),2)/(eval[i]+0.5)
    }
    
    for (k in 1:Birds){
    detect[k] ~ dunif(0,1) # Detection for each bird species
    alpha[k] ~ dnorm(intercept,tau_alpha)
    beta[k] ~ dnorm(gamma,tau_beta)    
    }
    
    #Hyperpriors
    gamma~dnorm(0,0.0001)
    intercept~dnorm(0,0.0001)
    
    tau_alpha ~ dgamma(0.0001,0.0001)
    sigma_int<-pow(1/tau_alpha,0.5) #Derived Quantity
    tau_beta ~ dgamma(0.0001,0.0001)
    sigma_slope<-pow(1/tau_beta,0.5)

    #derived posterior check
    fit<-sum(E[]) # sum Discrepancy for the observed data
    mfit<-mean(E[]) # mean Discrepancy for the observed data
    fitnew<-sum(E.new[]) # sum Discrepancy for a new draw from posterior
  
    }
    ",fill=TRUE)

sink()
