library(ggplot2)
library(scales)
ceph <- read.csv("ospd_ceph_bench_20150813.csv", header=TRUE)

png(file="ceph_perf.png", width=440)
ggplot(data=ceph, aes(x=factor(Test), y=(Relative.Performance), fill=(OSD.pg_num))) +
  geom_bar(stat="identity", position=position_dodge()) +
  scale_fill_manual(values=c("#000000", "#820000", "#CC0000")) +
  scale_y_continuous(breaks=pretty_breaks(n=8)) +
  ylab("Relative performance") + 
  ggtitle("Ceph benchmark -- increasing OSD and pg_num") +
  theme(axis.title.x=element_blank()) +
  theme(axis.text=element_text(size=12), axis.title=element_text(size=14,face="bold")) +
  theme(legend.position="bottom",legend.direction="horizontal", legend.title = element_blank())
dev.off()
