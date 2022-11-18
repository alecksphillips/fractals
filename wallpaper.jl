include("mandelbrot.jl")

img = drawMandelbrot((-0.95,0.3), (10240,2880), 20, 1000, 5, 0.05);

save(File{format"PNG"}("mandelbrot-wallpaper.png"), img)
