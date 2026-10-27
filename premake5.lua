-- Compressonator's CMP_Core (cmp_core/): the block encoders (BC1-BC7) the
-- editor's texture baker uses. Mirrors cmp_core/CMakeLists.txt, with its SSE/AVX/AVX-512 helper libraries
-- folded into this one project.

local root = _SCRIPT_DIR

CMPCoreIncludeDirs = { root .. "/cmp_core/source", root .. "/cmp_core/shaders" }

project "CMP_Core"
    kind "StaticLib"
    language "C++"
    cppdialect "C++17"
    staticruntime "on"
    warnings "Off"

    targetdir("%{wks.location}/bin/" .. outputdir .. "/%{prj.name}")
    objdir("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.name}")

    files
    {
        root .. "/cmp_core/source/cmp_core.h",
        root .. "/cmp_core/source/cmp_core.cpp",
        root .. "/cmp_core/source/core_simd_sse.cpp",
        root .. "/cmp_core/source/core_simd_avx.cpp",
        root .. "/cmp_core/source/core_simd_avx512.cpp",
        root .. "/cmp_core/shaders/bc1_encode_kernel.cpp",
        root .. "/cmp_core/shaders/bc2_encode_kernel.cpp",
        root .. "/cmp_core/shaders/bc3_encode_kernel.cpp",
        root .. "/cmp_core/shaders/bc4_encode_kernel.cpp",
        root .. "/cmp_core/shaders/bc5_encode_kernel.cpp",
        root .. "/cmp_core/shaders/bc6_encode_kernel.cpp",
        root .. "/cmp_core/shaders/bc7_encode_kernel.cpp",
        root .. "/applications/_libs/cmp_math/cpu_extensions.cpp",
        root .. "/applications/_libs/cmp_math/cmp_math_common.cpp",
    }

    includedirs
    {
        root .. "/cmp_core/source",
        root .. "/cmp_core/shaders",
        root .. "/applications/_libs/cmp_math",
    }

    defines { "_CRT_SECURE_NO_WARNINGS" }

    filter "files:**/core_simd_avx.cpp"
        buildoptions { "/arch:AVX2" }
    filter "files:**/core_simd_avx512.cpp"
        buildoptions { "/arch:AVX512" }
    filter {}

    filter "system:windows"
        systemversion "latest"

    filter "configurations:Debug"
        runtime "Debug"
        symbols "on"

    filter "configurations:Release or configurations:Dist"
        runtime "Release"
        optimize "on"
