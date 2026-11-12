-- NVIDIA (RTX 4050, the only GPU): video decode and GL go straight to the NVIDIA driver
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
