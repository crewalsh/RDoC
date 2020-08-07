paired_freq_plot <- function(data, conditions_list){
  #' a script to make plots for individual frequency time courses 
  #' @param data: data to plot; should be long format for one cluster/electrode 
  #' @param conditions_list: how high load, low load and load effect are coded in long data format
  #' @return list of 2 ggplot objects: low vs high load and load effect 
  #' 
  #' Written by C.Walsh 6/7/2020
  #' 
  
  rects <- data.frame(xstart=c(0,5500),xend=c(2500,7000),col = "gray")

  p1 <- ggplot(data = data)+
    geom_rect(data=rects,aes(xmin=xstart, xmax=xend, ymin = -Inf, ymax=Inf,alpha =0.005),fill="grey",show.legend = FALSE)+
    geom_line(data=data %>% filter(load==conditions_list[2]),aes(x=Time,y=Mean,color=level)) +
    geom_line(data=data %>% filter(load==conditions_list[1]),aes(x=Time,y=Mean,color=level),size=1,linetype="dotted")+
    scale_x_continuous(breaks = seq(-500,7000, by = 1000))+
    ylab("Mean Power")+
    #ggtitle(names(split_alphas_plot)[cluster])+
    ggtitle("Low Load vs High Load")+
    theme_classic()
  
  p2 <- ggplot(data=data)+
    geom_rect(data=rects,aes(xmin=xstart, xmax=xend, ymin = -Inf, ymax=Inf,alpha =0.005),fill="grey",show.legend = FALSE)+
    geom_line(data=data %>% filter(load==conditions_list[3]),aes(x=Time,y=Mean,color=level)) +
    ylab("Mean Activity") +
    xlab("Time (ms)")+
    geom_ribbon(data=data %>% filter(load == conditions_list[3]) %>% filter(level=="high"),aes(x=Time,ymin=SE_min, ymax=SE_max),alpha=.2,linetype=2,fill="red")+
    geom_ribbon(data=data %>% filter(load == conditions_list[3]) %>% filter(level=="med"),aes(x=Time,ymin=SE_min, ymax=SE_max),alpha=.2,linetype=2,fill="green")+
    geom_ribbon(data=data %>% filter(load == conditions_list[3]) %>% filter(level=="low"),aes(x=Time,ymin=SE_min, ymax=SE_max),alpha=.2,linetype=2,fill="blue")+
    scale_x_continuous(breaks = seq(-500,7000, by = 1000))+
    ylab("Mean Power Load Effect")+
    #ggtitle(names(split_alphas_plot)[cluster])+
    ggtitle("Load Effect")+
    theme_classic()+
    theme(legend.position = "none")
  
  return(list(indiv_loads=p1,load_effect=p2))
}