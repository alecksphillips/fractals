using DelimitedFiles, Colors

function colormapFromTSV(tsvFile)
  cmaparray = DelimitedFiles.readdlm(tsvFile)

  ncolors = size(cmaparray,1)
  
  cmap = Array{RGB{Float64},1}(undef,ncolors)

  for i in 1:ncolors
    cmap[i] = RGB{Float64}(cmaparray[i,1]/255, cmaparray[i,2]/255, cmaparray[i,3]/255)
  end
  
  return cmap
end
