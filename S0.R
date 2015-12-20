# this function will check if package is installed
# and if not it will install it
check_and_install <- function( packname ) {
    if ( packname %in% rownames(installed.packages()) == FALSE ) {
        install.packages( packname )
    }
}

check_and_install("data.table")
check_and_install("xtable")
check_and_install("ggplot2")
check_and_install("VIM")
