theme_luis <- function(base_size = 1.5){
  require(extrafont)
  color.background = 'white'
  color.grid.major = "grey85"
  color.axis.text = "grey20"
  color.axis.title = 'grey20'
  color.title = "grey30"
  color.subtitle = "#F14000"
  
  theme_bw(base_size= base_size * 9) +
    
    # Set the entire chart region to a light gray color
    theme(panel.background=element_rect(fill=color.background, color=color.background)) +
    theme(plot.background=element_rect(fill=color.background, color=color.background)) +
    theme(panel.border=element_rect(color=color.background)) +
    
    # Format the grid
    theme(panel.grid.major=element_line(color=color.grid.major,size=.25), axis.line = element_line(colour = "black", 
                                                                                                   size = rel(1))) +
    theme(panel.grid.minor=element_blank()) +
    theme(axis.ticks=element_blank()) +
    
    # Format the legend, but hide by default
    #theme(legend.position="none") +
    theme(legend.background = element_rect(fill=color.background)) +
    #theme(legend.text = element_text(size=1.2 * 7,color=color.axis.title)) +
    theme(legend.text = element_text(size= base_size * 7,color=color.axis.title)) + 
    
    # Set title and axis labels, and format these and tick marks
    theme(plot.subtitle=element_text(color=color.subtitle, size=15, vjust=1.25)) +
    theme(axis.text.x=element_text(size=base_size * 6,color=color.axis.text)) +
    theme(axis.text.y=element_text(size=base_size * 6,color=color.axis.text)) +
    theme(axis.title.x=element_text(size=base_size * 7,color=color.axis.title, vjust=0)) +
    theme(axis.title.y=element_text(size=base_size * 7,color=color.axis.title, vjust=1.25)) +
    
    # Plot margins
    theme(plot.margin = grid::unit(c(0.35, 0.2, 0.3, 0.35), "cm")) + 
    theme(text=element_text(size=base_size*9, family="Franklin Gothic Book")) +
    theme(plot.title=element_text(color=color.title, size=15, vjust=1.25, family="Franklin Gothic Book")) 
  
}

scale_color_luis <- function(theme="wes1", tech_key = list(
  wes1 = c("#E6A0C4", "#C6CDF7", "#D8A499", "#7294D4"),
  wes2 = c("#85D4E3", "#F4B5BD", "#9C964A", "#CDC08C", "#FAD77B"),
  unam = c("#55ACEE", "#292f33", "#8899a6", "#e1e8ed"),
  elegant = c('#16253D', '#002C54', '#EFB509', '#CD7123', "#E6A0C4"),
  procesos1 = c('#CD7123', '#FFFFFF'),
  procesos2 = c('#FFFFFF', '#CD7123')
)) {
  
  scale_color_manual(values=tech_key[[theme]])
  
}

scale_fill_luis <- function(theme="wes1", tech_key = list(
  wes1 = c("#E6A0C4", "#C6CDF7", "#D8A499", "#7294D4"),
  wes2 = c("#85D4E3", "#F4B5BD", "#9C964A", "#CDC08C", "#FAD77B"),
  unam = c("#55ACEE", "#292f33", "#8899a6", "#e1e8ed"),
  elegant = c('#16253D', '#002C54', '#EFB509', '#CD7123', "#E6A0C4"),
  procesos1 = c('#CD7123', '#FFFFFF'),
  procesos2 = c('#FFFFFF', '#CD7123')
)) {
  
  scale_fill_manual(values=tech_key[[theme]])

}

# data("iris")
# 
# d1 <- qplot(x  = Sepal.Length, y =Sepal.Width,colour = Species,data = iris,geom = "point") + theme_luis()
# d1 + scale_color_luis('elegant')
