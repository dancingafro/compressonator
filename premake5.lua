-- Compressonator for the editor's texture baker, as two static libraries:
--  - CMP_Core (cmp_core/): the block encoders (BC1-BC7). Mirrors cmp_core/CMakeLists.txt, with its
--    SSE/AVX/AVX-512 helper libraries folded into this one project.
--  - CMP_Compressonator (cmp_compressonatorlib/): the SDK, CMP_ConvertTexture and the codecs CMP_Core lacks
--    (ETC2 via ETCPack). Mirrors cmp_compressonatorlib/CMakeLists.txt without the optional parts (ASTC, which
--    upstream no longer supports, and Brotli-G).

local root = _SCRIPT_DIR
local lib = root .. "/cmp_compressonatorlib"

CMPCoreIncludeDirs = { root .. "/cmp_core/source", root .. "/cmp_core/shaders" }
CMPCompressonatorIncludeDirs = { lib }

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
    filter {}

project "CMP_Compressonator"
    kind "StaticLib"
    language "C++"
    cppdialect "C++17"
    staticruntime "on"
    warnings "Off"

    targetdir("%{wks.location}/bin/" .. outputdir .. "/%{prj.name}")
    objdir("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.name}")

    files
    {
        lib .. "/version.h",
        lib .. "/common.h",
        lib .. "/compress.cpp",
        lib .. "/compressonator.h",
        lib .. "/compressonator.cpp",
    }
    for _, folder in ipairs({ "apc", "atc", "ati", "basis", "bc6h", "bc7", "block", "buffer", "dxt", "dxtc", "etc", "etc/etcpack", "gt", "common" }) do
        files { lib .. "/" .. folder .. "/*.h", lib .. "/" .. folder .. "/*.cpp", lib .. "/" .. folder .. "/*.c", lib .. "/" .. folder .. "/*.cxx" }
    end
    files
    {
        root .. "/cmp_framework/common/*.h",
        root .. "/cmp_framework/common/*.cpp",
        root .. "/cmp_framework/common/half/*.h",
        root .. "/cmp_framework/common/half/*.cpp",
        root .. "/applications/_plugins/common/atiformats.cpp",
        root .. "/applications/_plugins/common/format_conversion.cpp",
        root .. "/applications/_plugins/common/codec_common.cpp",
        root .. "/applications/_plugins/common/texture_utils.cpp",
    }

    includedirs
    {
        lib,
        lib .. "/apc", lib .. "/atc", lib .. "/ati", lib .. "/basis", lib .. "/bc6h", lib .. "/bc7", lib .. "/block",
        lib .. "/buffer", lib .. "/dxt", lib .. "/dxtc", lib .. "/etc", lib .. "/etc/etcpack", lib .. "/gt", lib .. "/common",
        root .. "/cmp_framework/common",
        root .. "/cmp_framework/common/half",
        root .. "/applications/_plugins/common",
        root .. "/applications/_libs/cmp_math",
        root .. "/cmp_core/source",
        root .. "/cmp_core/shaders",
    }

    -- The subset of the top-level CMakeLists.txt definitions the library itself uses
    defines { "USE_ETCPACK", "ENABLE_MAKE_COMPATIBLE_API", "USE_OLD_SWIZZLE", "_CMP_CPP17_=1", "_CRT_SECURE_NO_WARNINGS", "NOMINMAX" }

    links { "CMP_Core" }

    filter "system:windows"
        systemversion "latest"

    filter "configurations:Debug"
        defines "_DEBUG"
        runtime "Debug"
        symbols "on"

    filter "configurations:Release or configurations:Dist"
        runtime "Release"
        optimize "on"
