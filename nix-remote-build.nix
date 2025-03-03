{ writeShellScriptBin, lib, openssh, nix, ... }:

writeShellScriptBin "nix-remote-build" ''
    set -eou pipefail

    ARGC=$#

    function print_help {
        echo "Usage: $0 [-c] [-n] -o <Flake-Output> -b <Build-Host>"
        echo ""
        echo "Options:"
        echo "-o      Flake output to build"
        echo "-b      Host to build on"
        echo "-c      Copy back built derivation after building"
        echo "-n      No signature check for copying back the built derivation"
    }

    COPY_BACK=0
    COPY_BACK_NO_SIG=0
    FLAKE_OUTPUT=""
    BUILD_HOST=""

    while getopts 'cno:b:h' opt; do
        case "$opt" in
            n)
                COPY_BACK_NO_SIG=1
                ;;
            c)
                COPY_BACK=1
                ;;
            o)
                FLAKE_OUTPUT=$OPTARG
                ;;
            b)
                BUILD_HOST=$OPTARG
                ;;
       
            ?|h)
                print_help
                exit 1
                ;;
        esac
    done

    if [[ -z $FLAKE_OUTPUT ]]; then
        echo "Error: no flake output given!"
        echo ""
        print_help
        exit 1
    fi

    if [[ -z $BUILD_HOST ]]; then
        echo "Error: no build host given!"
        echo ""
        print_help
        exit 1
    fi

    DRV_PATH=$(${lib.getExe nix} path-info --derivation $FLAKE_OUTPUT)

    ${lib.getExe nix} copy --derivation --to ssh-ng://$BUILD_HOST $FLAKE_OUTPUT

    OUT_PATH=$(${lib.getExe openssh} $BUILD_HOST nix build $DRV_PATH^* --print-out-paths)

    echo "Built $OUT_PATH on $BUILD_HOST"

    if [[ $COPY_BACK -eq 1 ]]; then
        if [[ $COPY_BACK_NO_SIG -eq 1 ]]; then
            ${lib.getExe nix} copy --from ssh-ng://$BUILD_HOST $OUT_PATH --no-check-sigs
        else
            ${lib.getExe nix} copy --from ssh-ng://$BUILD_HOST $OUT_PATH
        fi
        echo "Copied $OUT_PATH to local machine"
    fi
''
