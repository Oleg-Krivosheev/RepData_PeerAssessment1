### Are there differences in activity patterns between weekdays and weekends?

require("data.table")
require("xtable")
require("ggplot2")

unzip("activity.zip", "activity.csv")

# read and print
dt <- fread("activity.csv")
str(dt)

dims <- dim(dt)

# check
if (dims[1] != 17568) {
    stop("Bad number of rows, should be 17568, bailing out!")
}

if (dims[2] != 3) {
    stop("Bad number of columns, should be 3, bailing out!")
}

# make date proper
dt <- dt[ , date := as.Date(date, "%Y-%m-%d")]
print(str(dt))

# make a good primary key
setkey(dt, date)

wd_or_we <- function(theday) {
    v <- ""

    if (theday == "Saturday") {
        v <- "weekend"
    } else if (theday == "Sunday") {
        v <- "weekend"
    } else {
        v <- "weekday"
    }
    v
}

dt[, wd := as.POSIXlt(dt$date)$wday + 1]
min(dt$wd)
max(dt$wd)
thedays <- c("weekend", rep("weekday",5), "weekend")
dt[, nwd := as.factor(thedays[dt$wd])]
str(dt)
print(dt)

q <- dt$nwd == "weekday"
print(sum(q))
qq <- dt$nwd == "weekend"
print(sum(qq))
