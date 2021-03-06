do_cdfband = function(x,g,theta,gd){
    x.df <-data.frame(x = x)
    n <- dim(x.df)[1]
    fun.ecdf <- ecdf(x.df$x)
    ecdf.val <- fun.ecdf(sort(x.df$x))
    
    ecdf.df <- data.frame(x = sort(x.df$x), ecdf.val=ecdf.val)
    lwr = ecdf.df$ecdf.val-1.358*n^(-0.5)
    upr = ecdf.df$ecdf.val+1.358*n^(-0.5)
    predframe <- data.frame(cbind(ecdf.df, lwr, upr))
    dd = ggplot(ecdf.df,aes(x))+
         geom_line(aes(y=ecdf.val,colour="Sample")) +
         geom_ribbon(data=predframe,aes(ymin=lwr,ymax=upr),alpha=0.3)+
         labs(title='CDF with K-S C.I band',x='data',y='prob')+theme(legend.title=element_blank())
    
    if(!is.null(gd)){ #can't use build-in distribution
      num = unique(ecdf.df$x)
      cdf.probs = cumsum(gd(num))
      cdf.map = list(num=num,cdf.val=cdf.probs)
      ecdf.df$cdf= sapply(ecdf.df$x, function(x) cdf.map$cdf.val[which(cdf.map$num==x)])
      dd = dd + geom_line(aes(y=ecdf.df$cdf,colour="New Estimation"))
    }
    
    if(g =="poisson"){
      ecdf.df$cdf=ppois(sort(x.df$x),lambda = theta[1])
      dd = dd + geom_line(aes(y=ecdf.df$cdf,colour="Pois Estimation"))   
    } 
    
    if(g=="negative binomial"){
      ecdf.df$cdf=pnbinom(sort(x.df$x),size = theta[1],prob = theta[2])
      dd = dd + geom_line(aes(y=ecdf.df$cdf,colour="Negtive Binomial Estimation"))   
    }
    
    if(g=="gamma"){
      ecdf.df$cdf=pgamma(sort(x.df$x),shape=theta[1],scale=theta[2])
      dd = dd + geom_line(aes(y=ecdf.df$cdf,colour="Gamma Estimation"))   
    }
    
    if(g=="beta"){
      ecdf.df$cdf=pbeta(sort(x.df$x),theta[1],theta[2])
      dd = dd + geom_line(aes(y=ecdf.df$cdf,colour="Beta Estimation"))
    }
    
    if(g=="power law"){
      gamma = theta[1]
      test.sum = 0
      k = 1
      last.sum = 1
      while(abs(test.sum-last.sum) > 10e-6){
        last.sum = test.sum
        test.sum = test.sum + k^(-gamma)
        k=k+1
      }
      c = 1/test.sum  #more robust to calculate c
      pdf.f = function(k) c*k^(-gamma)
      num = unique(ecdf.df$x)
      cdf.probs = cumsum(pdf.f(num))
      cdf.map = list(num=num,cdf.val=cdf.probs)
      ecdf.df$cdf= sapply(ecdf.df$x, function(x) cdf.map$cdf.val[which(cdf.map$num==x)])
      dd = dd + geom_line(aes(y=ecdf.df$cdf,colour="Power Law Estimation"))
    }
    
    if(g=="mixture of 2 poissons"){
      ecdf.df$cdf=theta[3]*ppois(sort(x.df$x),theta[1])+(1-theta[3])*ppois(sort(x.df$x),theta[2])
      dd = dd + geom_line(aes(y=ecdf.df$cdf,colour="Mixed 2 Pois Estimation"))    
    }
    
    if(g=="mixture of 2 exponentials"){
      ecdf.df$cdf=theta[3]*pexp(sort(x.df$x),rate = 1.0/theta[1])+(1-theta[3])*pexp(sort(x.df$x),rate = 1.0/theta[2])
      dd = dd + geom_line(aes(y=ecdf.df$cdf,colour="Mixed 2 Exp Estimation"))    
    }
    
    if(g=="mixture of 2 normals"){
      ecdf.df$cdf=theta[5]*pnorm(sort(x.df$x),mean=theta[1],sd = theta[2])+(1-theta[5])*pnorm(sort(x.df$x),mean = theta[3],sd = theta[4])
      dd = dd + geom_line(aes(y=ecdf.df$cdf,colour="Mixed 2 Norm Estimation"))    
     }

  return(dd)
}