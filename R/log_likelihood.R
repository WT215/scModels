#' Negative log Likelihood functions for Poisson, negative binomial and
#' Poisson-beta distributions
#'
#' The negative log Likelihood functions for Poisson, negative binomial
#' Poisson-inverse Gaussian and Poisson-beta distributions. Mixing two
#' distributions of the same kind and/or adding zero-inflation allows
#' to take characteristics of real data into account.
#' Additionally, one population and two population mixtures - with and
#' without zero-inflation - allow distribution fitting of the Poisson,
#' negative binomial, Poisson-inverse Gaussian and the Poisson-beta distribution.
#'
#'
#' @details
#' Functions nlogL_pois, nlogL_nb, nlogL_pig, nlogL_pb compute the negative
#' log-likelihood of Poisson, negative binomial, Poisson-inverse Gaussian and
#' the Poisson-beta distributions given the data.
#' Functions nlogL_pois2, nlogL_nb2, nlogL_pig2 and nlogL_pb2 compute the negative
#' log-likelihood values for a two population mixture of distributions whereas
#' nlogL_zipois, nlogL_zinb, nlogL_zipig, nlogL_zipb compute the same for the
#' zero-inflated distributions. Furthermore, nlogL_zipois2, nlogL_zinb2, nlogL_zipig2
#' and nlogL_zipb2 are for two population mixtures with zero-inflation.


#' @param data Vector containing the discrete observations
#' @param par.pois Scalar containing the lambda parameter
#'     of the Poisson distribution
#' @param par.nb Vector of length 2, containing the size and the mu
#'     parameter of the negative binomial distribution
#' @param par.pig Vector of length 2, containing the mu and the sigma
#'   parameter of the Poisson-inverse Gaussian distribution
#' @param par.pb Vector of length 3, containing the alpha, beta
#'     and c parameter of the Poisson-beta distribution
#' @param par.pois2,par.nb2,par.pig2,par.pb2 Vector containing the parameters
#'     of the two mixing distributions. First entry represents the
#'     fraction of the first distribution, followed by all parameters
#'     of the first, then all of the second distribution.
#' @param par.zipois,par.zinb,par.zipig,par.zipb Vector containing the respective
#'     zero-inflated distribution parameters. The additional first
#'     entry is the inflation parameter for all cases.
#' @param par.zipois2,par.zinb2,par.zipig2,par.zipb2 Parameters for the zero-inflated
#'     two population model.
#'
#' @keywords likelihood negative binomial Poisson-beta
#'
#' @name nlogL
#' @importFrom stats dpois dnbinom rnorm rpois rnbinom
#' @importFrom gamlss.dist dPIG dZIPIG rPIG rZIPIG
#' @export
#' @examples
#' x <- rpois(100, 11)
#' nl1 <- nlogL_pois(x, 11)
#' nl2 <- nlogL_pois(x, 13)
nlogL_pois <- function(data, par.pois) {
  if (par.pois <= 0) {
    return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
  } else {
    nl <- -sum(dpois(x = data, lambda = par.pois, log = TRUE))
    if (is.infinite(nl))
      return (nl_inf + (rnorm(1, 10000, 20) ^ 2))
    else
      return(nl)
  }
}


#' @rdname nlogL
#' @export
#' @examples
#' x <- rnbinom(100, size = 13, mu = 9)
#' nl <- nlogL_nb(x, c(13, 9))
nlogL_nb <- function(data, par.nb) {
  if (par.nb[1] <= 0 || par.nb[2] < 0) {
    return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
  } else {
    nl <- -sum(dnbinom(x = data, size = par.nb[1], mu = par.nb[2], log = TRUE))
    if (is.infinite(nl))
      return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    else
      return(nl)
  }
}

#' @rdname nlogL
#' @export
#' @examples
#' x <- gamlss.dist::rPIG(100, mu = 5, sigma = 0.2)
#' nl <- nlogL_pig(x, c(13, 9))


nlogL_pig <- function(data, par.pig) {
    if (par.pig[1] <= 0 || par.pig[2] < 0) {
        return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    } else {
        nl <- -sum(dPIG(x = data, mu = par.pig[1], sigma = par.pig[2], log = TRUE))
        if (is.infinite(nl))
            return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
        else
            return(nl)
    }
}


#' @rdname nlogL
#' @export
#' @examples
#' x <- rpb(n = 1000, alpha=5, beta= 3, c=20)
#' nl <- nlogL_pb(x, c(5, 3, 20))
nlogL_pb <- function(data, par.pb) {
  if (par.pb[1] < 0 ||
      par.pb[2] < 0 || par.pb[3] <= 0) {
    return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
  } else {
    nl <- -sum(dpb(x = data, alpha = par.pb[1], beta = par.pb[2], c = par.pb[3], log = TRUE))
    if (is.infinite(nl))
      return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    else
      return(nl)
  }
}

sum_2pop_terms <- function(t1, t2) {
  b1 <- (t1)/log(10) -300
  b3 <- (t2)/log(10) -300
  b13 <- pmax(b1,b3)
  b2 <- (t1)/log(10) +300
  b4 <- (t2)/log(10) +300
  b24 <- pmin(b2,b4)
  b <- rowMeans(matrix(c(b1*is.finite(b1),b2*is.finite(b2),b3*is.finite(b3),b4*is.finite(b4)),ncol = 4, byrow= FALSE), na.rm = TRUE )

  t1_b <- (t1 / log(10)-b)
  t2_b <- (t2 / log(10)-b)

  t_b_check_1<- (t2_b - t1_b > 600)
  t_b_check_2<- (t1_b - t2_b > 600)


  nl <- sum( b[!t_b_check_1 & !t_b_check_2]*log(10) + log( 10 ^(t1[!t_b_check_1 & ! t_b_check_2] / log(10)-b[!t_b_check_1 & !t_b_check_2]) + 10 ^(t2[ !t_b_check_1 & !t_b_check_2] / log(10)-b[!t_b_check_1 & !t_b_check_2])))+
    sum( (t2[t_b_check_1]  )) + sum( (t1[t_b_check_2]  ))
  return(-nl)
}

#' @rdname nlogL
#' @export
#' @examples
#' s <- sample(x = c(0,1), size = 100, replace = TRUE, prob = c(0.3,0.7))
#' x <- s*rpois(100, 7) + (1-s)*rpois(100, 13)
#' nl1 <- nlogL_pois2(x, c(0.7, 13, 7))
#' nl2 <- nlogL_pois2(x, c(0.3, 7, 13))
#' ## both values should be same: 296.9517
nlogL_pois2 <- function(data, par.pois2) {
  if (par.pois2[2] <= 0 ||
      par.pois2[3] <= 0 ||
      par.pois2[1] < 0 ||
      par.pois2[1] > 1) {
    return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
  }
  else if (par.pois2[1] == 0) {
    new.par.pois2 <- c(1, par.pois2[c(3, 2)])
    return(nlogL_pois2(data, new.par.pois2))
  }
  else {
    t1 <- log(par.pois2[1])+dpois(x = data, lambda = par.pois2[2], log = TRUE)
    t2 <- log(1-par.pois2[1])+dpois(x = data, lambda = par.pois2[3], log = TRUE)
    nl <- sum_2pop_terms(t1, t2)
    if (is.infinite(nl))
      return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    else{
      return(nl)
    }
  }
}


#' @rdname nlogL
#' @export
#' @examples
#' s <- sample(x = c(0,1), size = 100, replace = TRUE, prob = c(0.3,0.7))
#' x <-s*rnbinom(100, size = 13, mu = 9) + (1-s)*rnbinom(100, size = 17, mu = 29)
#' nl <- nlogL_nb2(x, c(0.7, 17, 29, 13, 9))
nlogL_nb2 <- function(data, par.nb2) {
  if (par.nb2[2] <= 0 ||
      par.nb2[3] < 0 ||
      par.nb2[4] <= 0 ||
      par.nb2[5] < 0 ||
      par.nb2[1] < 0 ||
      par.nb2[1] > 1) {
    return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
  }
  else if (par.nb2[1] == 0) {
    new.par.nb2 <- c(1, par.nb2[c(4, 5, 2, 3)])
    return(nlogL_nb2(data, new.par.nb2))
  }
  else {
    t1 <- log(par.nb2[1]) + dnbinom(x = data,size = par.nb2[2],mu = par.nb2[3],log = TRUE)
    t2 <- log(1-par.nb2[1]) + dnbinom(x = data,size = par.nb2[4],mu = par.nb2[5],log = TRUE)
    nl <- sum_2pop_terms(t1, t2)
    if (is.infinite(nl))
      return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    else
      return(nl)
  }
}


#' @rdname nlogL
#' @export
#' @examples
#' s <- sample(x = c(0,1), size = 100, replace = TRUE, prob = c(0.3,0.7))
#' x <-s*gamlss.dist::rPIG(100, mu = 5, sigma = 0.2) + (1-s)*gamlss.dist::rPIG(100, mu = 20, sigma = 2)
#' nl <- nlogL_pig2(x, c(0.7, 20, 2, 5, 0.2))
nlogL_pig2 <- function(data, par.pig2) {
    if (par.pig2[2] < 0 ||
        par.pig2[3] < 0 ||
        par.pig2[4] < 0 ||
        par.pig2[5] < 0 ||
        par.pig2[1] < 0 ||
        par.pig2[1] > 1) {
        return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    }
    else if (par.pig2[1] == 0) {
        new.par.pig2 <- c(1, par.pig2[c(4, 5, 2, 3)])
        return(nlogL_pig2(data, new.par.pig2))
    }
    else {
        t1 <- log(par.pig2[1]) + dPIG(x = data,mu = par.pig2[2],sigma = par.pig2[3],log = TRUE)
        t2 <- log(1-par.pig2[1]) + dPIG(x = data,mu = par.pig2[4],sigma = par.pig2[5],log = TRUE)
        nl <- sum_2pop_terms(t1, t2)
        if (is.infinite(nl))
            return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
        else
            return(nl)
    }
}

#' @rdname nlogL
#' @export
#' @examples
#' s <- sample(x = c(0,1), size = 100, replace = TRUE, prob = c(0.3,0.7))
#' x <- s*rpb(100, 5, 3, 20) + (1-s)*rpb(100, 7, 13, 53)
#' nl <- nlogL_pb2(x, c(0.7, 7, 13, 53, 5, 3, 20))
nlogL_pb2 <- function(data, par.pb2) {
  if (par.pb2[2] < 0 ||
      par.pb2[3] < 0 ||
      par.pb2[4] <= 0 ||
      par.pb2[5] < 0 ||
      par.pb2[6] < 0 ||
      par.pb2[7] <= 0 ||
      par.pb2[1] < 0 ||
      par.pb2[1] > 1) {
    return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
  }
  else if (par.pb2[1] == 0) {
    new.par.pb2 <- c(1, par.pb2[c(5:7, 2:4)])
    return(nlogL_pb2(data, new.par.pb2))
  }
  else {
    t1 <- log(par.pb2[1]) + dpb(x = data, alpha = par.pb2[2], beta = par.pb2[3], c = par.pb2[4], log = TRUE)
    t2 <- log(1-par.pb2[1]) + dpb(x = data, alpha = par.pb2[5], beta = par.pb2[6], c = par.pb2[7], log = TRUE)
    nl <- sum_2pop_terms(t1, t2)
    if (is.infinite(nl))
      return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    else{
      return(nl)
    }
  }
}



#' @rdname nlogL
#' @export
#' @examples
#' x <- c(rep(0, 10), rpois(90, 7))
#' nl <- nlogL_zipois(x, c(0.1, 7))
nlogL_zipois <- function(data, par.zipois) {
  if (par.zipois[2] <= 0 ||
      par.zipois[1] < 0 ||
      par.zipois[1] > 1) {
    return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
  }
  else {
    n <- length(data)
    n0 <- length(which(data == 0))
    non_zero <- data[which(data != 0)]
    if(n0 == 0) {
      t1 = 0
    }
    else {
      l <- log(par.zipois[1] + (1 - par.zipois[1]) * exp(-par.zipois[2]))

      # This can happen when the inflation parameter is 0 and the probability
      # of a 0 is very low. For an explanation, see this:
      #>>>> > exp(-1259)
      #>>>> [1] 0
      if(is.nan(l)){
        t1 = -par.zipois[2]
      }
      else {
        t1 <- l
      }
    }
    nl <- n0 * t1 + (n - n0) * log(1 - par.zipois[1]) + sum(dpois(x = non_zero, lambda = par.zipois[2], log = TRUE))
    nl <- -nl
    if (is.infinite(nl))
      return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    else{
      return(nl)
    }
  }
}

#' @rdname nlogL
#' @export
#' @examples
#' x <- c(rep(0,10), rnbinom(90, size = 13, mu = 9))
#' nl <- nlogL_zinb(x, c(0.1, 13, 9))
nlogL_zinb <- function(data, par.zinb) {
  if (par.zinb[2] <= 0 ||
      par.zinb[3] < 0 ||
      par.zinb[1] < 0 ||
      par.zinb[1] > 1) {
    return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
  }
  else {
    n <- length(data)
    n0 <- length(which(data == 0))
    non_zero <- data[which(data != 0)]
    if(n0 == 0) {
      t1 = 0
    }
    else {
      l <- log(par.zinb[1] + (1 - par.zinb[1])*dnbinom(0, size = par.zinb[2], mu = par.zinb[3]))

      # Motivated by conclusions from zipois, but the same scenario
      # occurs in less cases here. The nestorowa dataset had convergent fits
      # for all cases without this condition.
      if(is.nan(l)){
        t1 = dnbinom(0, size = par.zinb[2], mu = par.zinb[3], log = TRUE)
      }
      else {
        t1 <- l
      }
    }
    nl <- n0 * t1 + (n-n0)*log(1-par.zinb[1])+sum(dnbinom(x = non_zero, size = par.zinb[2], mu = par.zinb[3], log = TRUE))
    nl <- -nl
    if (is.infinite(nl))
      return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    else{
      return(nl)
    }
  }
}

#' @rdname nlogL
#' @export
#' @examples
#' x <- c(rep(0,10), gamlss.dist::rPIG(90, mu = 13, sigma = 2))
#' nl <- nlogL_zipig(x, c(0.1, 13, 2))
nlogL_zipig <- function(data, par.zipig) {
    if (par.zipig[2] < 0 ||
        par.zipig[3] < 0 ||
        par.zipig[1] < 0 ||
        par.zipig[1] > 1) {
        return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    } else {
      n0 <- length(which(data == 0))
      if(par.zipig[1]==0) {
        nl= -sum(dPIG(x = data, mu = par.zipig[2], sigma = par.zipig[3], log = TRUE))
      }
      else {
        nl <- -sum(dZIPIG(data, mu = par.zipig[2], sigma = par.zipig[3], nu = par.zipig[1], log = TRUE))
      }
        if (is.infinite(nl))
            return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
        else
            return(nl)
    }
}


#' @rdname nlogL
#' @export
#' @examples
#' x <- c(rep(0, 10), rpb(n = 90, alpha=5, beta= 3, c=20))
#' nl <- nlogL_zipb(x, c(0.1, 5, 3, 20))
nlogL_zipb <- function(data, par.zipb) {
  if (par.zipb[2] < 0 ||
      par.zipb[3] < 0 ||
      par.zipb[4] <= 0 ||
      par.zipb[1] < 0 ||
      par.zipb[1] > 1) {
    return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
  }
  else {
    n <- length(data)
    n0 <- length(which(data == 0))
    non_zero <- data[which(data != 0)]
    if(n0 == 0) {
      t1 = 0
    }
    else{
      l <- log(par.zipb[1] + (1 - par.zipb[1])*dpb(0, par.zipb[2], par.zipb[3], par.zipb[4]))
      if(is.nan(l)){

        # Going by the change from zipois to zinb [more parameters => better fit?],
        # maybe even lesser cases happen here. Inference not tested.
        t1 = dpb(0, par.zipb[2], par.zipb[3], par.zipb[4], log = TRUE)
      }
      else {
        t1 <- l
      }
    }
    nl <- n0 * t1 + (n-n0)*log(1-par.zipb[1])+sum(dpb(x = non_zero, par.zipb[2], par.zipb[3], par.zipb[4], log = TRUE))
    nl <- -nl
    if (is.infinite(nl))
      return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    else{
      return(nl)
    }
  }
}


#' @rdname nlogL
#' @export
#' @examples
#' s <- sample(x = c(0,1), size = 90, replace = TRUE, prob = c(0.3,0.7))
#' x <- c(rep(0, 10), s*rpois(90, 7) + (1-s)*rpois(90, 13))
#' nl1 <- nlogL_zipois2(x, c(0.1, 0.63, 13, 7))
nlogL_zipois2 <- function(data, par.zipois2) {
  if (par.zipois2[1] < 0 ||
      par.zipois2[1] > 1 ||
      par.zipois2[2] < 0 ||
      par.zipois2[2] > 1 ||
      par.zipois2[1] + par.zipois2[2] > 1 ||
      par.zipois2[3] <= 0 ||
      par.zipois2[4] <= 0) {
    return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
  }
  else if (par.zipois2[2] == 0) {
    new.par.zipois2 <- c(par.zipois2[1], 1- par.zipois2[1], par.zipois2[c(4, 3)])
    return(nlogL_zipois2(data, new.par.zipois2))
  }
  else {
    n <- length(data)
    n0 <- length(which(data == 0))
    non_zero <- data[which(data != 0)]

    t1 <- log(par.zipois2[2])+dpois(x = 0, lambda = par.zipois2[3], log = TRUE)
    t2 <- log(1-(par.zipois2[1]+par.zipois2[2]))+dpois(x = 0, lambda = par.zipois2[4], log = TRUE)
    nl_zero <- -sum_2pop_terms(t1, t2)

    t1 <- log(par.zipois2[2])+dpois(x = non_zero, lambda = par.zipois2[3], log = TRUE)
    t2 <- log(1-(par.zipois2[1]+par.zipois2[2]))+dpois(x = non_zero, lambda = par.zipois2[4], log = TRUE)
    nl_non_zero <- -sum_2pop_terms(t1, t2)

    # reduce expression when no zero-inflation
    if(par.zipois2[1] == 0)
      nl <- n0 * nl_zero + nl_non_zero
    else
      nl <- n0 * log(par.zipois2[1] + exp(nl_zero ) ) + nl_non_zero
    nl <- -nl
    if (is.infinite(nl))
      return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    else{
      return(nl)
    }
  }
}



#' @rdname nlogL
#' @export
#' @examples
#' s <- sample(x = c(0,1), size = 90, replace = TRUE, prob = c(0.3,0.7))
#' x <- c(rep(0, 10), s*rnbinom(90, size = 13, mu = 9) + (1-s)*rnbinom(90, size = 17, mu = 29))
#' nl <- nlogL_zinb2(x, c(0.1, 0.63, 17, 29, 13, 9))
nlogL_zinb2 <- function(data, par.zinb2) {
  if (par.zinb2[1] < 0 ||
      par.zinb2[1] > 1 ||
      par.zinb2[2] < 0 ||
      par.zinb2[2] > 1 ||
      par.zinb2[1] + par.zinb2[2] > 1 ||
      par.zinb2[3] <= 0 ||
      par.zinb2[4] < 0 ||
      par.zinb2[5] <= 0 ||
      par.zinb2[6] < 0) {
    return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
  }
  else if (par.zinb2[2] == 0) {
    new.par.zinb2 <- c(par.zinb2[1], 1 - par.zinb2[1], par.zinb2[c(5, 6, 3, 4)])
    return(nlogL_zinb2(data, new.par.zinb2))
  }
  else {
    n <- length(data)
    n0 <- length(which(data == 0))
    non_zero <- data[which(data != 0)]

    t1 <- log(par.zinb2[2]) + dnbinom(x = 0, size = par.zinb2[3], mu = par.zinb2[4], log = TRUE)
    t2 <- log(1 - (par.zinb2[1] + par.zinb2[2])) + dnbinom(x = 0, size = par.zinb2[5], mu = par.zinb2[6], log = TRUE)
    nl_zero <- -sum_2pop_terms(t1, t2)

    t1 <- log(par.zinb2[2]) + dnbinom(x = non_zero, size = par.zinb2[3], mu = par.zinb2[4], log = TRUE)
    t2 <- log(1 - (par.zinb2[1] + par.zinb2[2])) + dnbinom(x = non_zero, size = par.zinb2[5], mu = par.zinb2[6], log = TRUE)
    nl_non_zero <- -sum_2pop_terms(t1, t2)

    if(par.zinb2[1] == 0)
      nl <- n0 * nl_zero + nl_non_zero
    else
      nl <- n0 * log(par.zinb2[1] + exp(nl_zero ) ) + nl_non_zero
    nl <- -nl
    if (is.infinite(nl))
      return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    else{
      return(nl)
    }
  }
}

#' @rdname nlogL
#' @export
#' @examples
#' s <- sample(x = c(0,1), size = 90, replace = TRUE, prob = c(0.3,0.7))
#' x <- c(rep(0, 10), s*gamlss.dist::rPIG(90, mu = 13, sigma = 0.2) + (1-s)*gamlss.dist::rPIG(90, mu = 17, sigma = 2))
#' nl <- nlogL_zipig2(x, c(0.1, 0.63, 17, 2, 13, 0.2))
nlogL_zipig2 <- function(data, par.zipig2) {
    if (par.zipig2[1] < 0 ||
        par.zipig2[1] > 1 ||
        par.zipig2[2] < 0 ||
        par.zipig2[2] > 1 ||
        par.zipig2[1] + par.zipig2[2] > 1 ||
        par.zipig2[3] < 0 ||
        par.zipig2[4] < 0 ||
        par.zipig2[5] < 0 ||
        par.zipig2[6] < 0) {
        return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    }
    else if (par.zipig2[2] == 0) {
        new.par.zipig2 <- c(par.zipig2[1], 1 - par.zipig2[1], par.zipig2[c(5, 6, 3, 4)])
        return(nlogL_zipig2(data, new.par.zipig2))
    }
    else {
        n <- length(data)
        n0 <- length(which(data == 0))
        non_zero <- data[which(data != 0)]

        t1 <- log(par.zipig2[2]) + dPIG(x = 0, mu = par.zipig2[3], sigma = par.zipig2[4], log = TRUE)
        t2 <- log(1 - (par.zipig2[1] + par.zipig2[2])) + dPIG(x = 0, mu = par.zipig2[5], sigma = par.zipig2[6], log = TRUE)
        nl_zero <- -sum_2pop_terms(t1, t2)

        t1 <- log(par.zipig2[2]) + dPIG(x = non_zero, mu = par.zipig2[3], sigma = par.zipig2[4], log = TRUE)
        t2 <- log(1 - (par.zipig2[1] + par.zipig2[2])) + dPIG(x = non_zero, mu = par.zipig2[5], sigma = par.zipig2[6], log = TRUE)
        nl_non_zero <- -sum_2pop_terms(t1, t2)

        if(par.zipig2[1] == 0)
            nl <- n0 * nl_zero + nl_non_zero
        else
            nl <- n0 * log(par.zipig2[1] + exp(nl_zero ) ) + nl_non_zero
        nl <- -nl
        if (is.infinite(nl))
            return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
        else{
            return(nl)
        }
    }
}

#' @rdname nlogL
#' @export
#' @examples
#' s <- sample(x = c(0,1), size = 90, replace = TRUE, prob = c(0.3,0.7))
#' x <- c(rep(0,10), s*rpb(90, 5, 3, 20) + (1-s)*rpb(90, 7, 13, 53))
#' nl <- nlogL_zipb2(x, c(0.1, 0.63, 7, 13, 53, 5, 3, 20))
nlogL_zipb2 <- function(data, par.zipb2) {
  if (par.zipb2[1] < 0 ||
      par.zipb2[1] > 1 ||
      par.zipb2[2] < 0 ||
      par.zipb2[2] > 1 ||
      par.zipb2[1] + par.zipb2[2] > 1 ||
      par.zipb2[3] < 0 ||
      par.zipb2[4] < 0 ||
      par.zipb2[5] <= 0 ||
      par.zipb2[6] < 0 ||
      par.zipb2[7] < 0 ||
      par.zipb2[8] <= 0) {
    return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
  }
  else if (par.zipb2[2] == 0) {
    new.par.zipb2 <- c(par.zipb2[1], 1 - par.zipb2[1], par.zipb2[c(6:8, 3:5)])
    return(nlogL_zipb2(data, new.par.zipb2))
  }
  else {
    n <- length(data)
    n0 <- length(which(data == 0))
    non_zero <- data[which(data != 0)]

    t1 <- log(par.zipb2[2]) + dpb(x = 0, alpha = par.zipb2[3], beta = par.zipb2[4], c = par.zipb2[5], log = TRUE)
    t2 <- log(1 - (par.zipb2[1] + par.zipb2[2])) + dpb(x = 0, alpha = par.zipb2[6], beta = par.zipb2[7], c = par.zipb2[8], log = TRUE)
    nl_zero <- -sum_2pop_terms(t1, t2)

    t1 <- log(par.zipb2[2]) + dpb(x = non_zero, alpha = par.zipb2[3], beta = par.zipb2[4], c = par.zipb2[5], log = TRUE)
    t2 <- log(1 - (par.zipb2[1] + par.zipb2[2])) + dpb(x = non_zero, alpha = par.zipb2[6], beta = par.zipb2[7], c = par.zipb2[8], log = TRUE)
    nl_non_zero <- -sum_2pop_terms(t1, t2)

    if(par.zipb2[1] == 0)
      nl <- n0 * nl_zero + nl_non_zero
    else
      nl <- n0 * log(par.zipb2[1] + exp(nl_zero ) ) + nl_non_zero
    nl <- -nl
    if (is.infinite(nl))
      return(nl_inf + (rnorm(1, 10000, 20) ^ 2))
    else{
      return(nl)
    }
  }
}

nl_inf <- 1e+100
