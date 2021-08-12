spearman_corr = function(x,y){
  # finding coefficient
  n = length(x)
  x_rank = rank(-x, ties.method = "first")
  y_rank = rank(-y, ties.method = "first")
  diff_sq = (x_rank - y_rank)^2
  coefficient = 1 - (6*sum(diff_sq))/(n*(n^2-1))
  # finding t stat
  t_stat = coefficient * sqrt((n - 2)/(1-coefficient^2))
  # finding p value
  p_val = pt(q = -t_stat, df = n - 2, lower.tail = F)*2
  
  return(lst = list(coefficient = coefficient, t_stat = t_stat, p_value = p_val))
  
}

spearman_corr(nedl$`Log GDP per capita`, nedl$`GDP per capita growth`)


