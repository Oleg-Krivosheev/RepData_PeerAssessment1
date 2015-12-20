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

# steps per day
dt.steps_by_date <- dt[, sum(steps), by=date]
setnames(dt.steps_by_date, "V1", "total_steps")
#print(dt.steps_by_date)

tbl <- dt.steps_by_date[, list(n = .N,  mean = mean(total_steps, na.rm=TRUE), median = median(total_steps, na.rm=TRUE))]
print(tbl)
print(xtable(tbl), type="html", include.rownames=FALSE)
