library(Spectra)

sp1_df = read_csv("C84H93Cl2N9O31_predicted_plus1.csv")
sp2_df = read_csv("C84H93Cl2N9O31_obs_plus1.csv")



sp1 <- DataFrame(msLevel = 1L, rtime = 1)
sp1$mz = list(sp1_df$mz)
sp1$intensity = list(sp1_df$intensity/max(sp1_df$intensity))
sp1 = Spectra(sp1)


sp2 <- DataFrame(msLevel = 1L, rtime = 1)
sp2$mz = list(sp2_df$mz)
sp2$intensity = list(sp2_df$intensity/max(sp2_df$intensity))
sp2 = Spectra(sp2)


svg("C84H93Cl2N9O31_isotopepattern_plus1.svg",width = 15,height=7)
plotSpectraMirror(sp1,sp2,  col = "black",
                  labels = function(z) {
                    lbls <- format(mz(z)[[1L]], digits = 6)
                    lbls[intensity(z)[[1L]] <= 0.02] <- ""
                    lbls
                  },
                  #labelSrt = -30,
                  labelPos = 2, labelOffset = 0.2, labelCol ="black",
                  ppm = 10,
                  matchCol = "red", matchLwd = 1, matchPch = NA,
                  xlim = c(1794,1802),
                  cex.lab=2,labelCex=2,cex.axis=2
                  )
dev.off()


sp1_df = read_csv("897_ms2.csv")
sp1 <- DataFrame(msLevel = 1L, rtime = 1)
sp1$mz = list(sp1_df$mz)
sp1$intensity = list(sp1_df$intensity/max(sp1_df$intensity))
sp1 = Spectra(sp1)


svg("897_msms_full.svg",width = 15,height=3)
#svg("897_msms_full.svg",width = 7,height=6)

target_mz=c(1651.4508,1665.4652,1691.4797,1548.3826,1634.4195)
x_range = c(1630,1700)
# target_mz=c(127.0757,130.0863,100.076,144.163)
# x_range=c(100,150)
plotSpectra(sp1,
            # labels = function(z) {
            #   lbls <- mz(z)[[1L]]
            #   lbls[!lbls%in%target_mz] = ""
            #   lbls = format(lbls, digits=6)
            #   # lbls[intensity(z)[[1L]] <= 0.05] <- ""
            #   lbls
            # },
            col="black",labelCol = "black",
           # xlim=x_range,
          #  ylim = c(0,0.15),
          frame.plot=T,axes=T,ylab="intensity",main=NA,
          cex.lab=2,labelCex=2,cex.axis=2
          )
dev.off()