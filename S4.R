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

# 1. Calculate and report the total number of missing values in the dataset (i.e. the total number of rows with `NA`s)

q <- is.na(dt$steps)
print(sum(q))

# 2. Devise a strategy for filling in all of the missing values in the dataset. The strategy does not need to be sophisticated. For example, you could use the mean/median for that day, or the mean for that 5-minute interval, etc.

# helper DT with only two columns
dt.med = dt[, list(mean=mean(steps, na.rm=TRUE)), by=interval]
#print(dt.med, n=288)

dt.imp <- copy(dt)
str(dt.imp)

for (k in seq_len(nrow(dt.imp))) {
    if (is.na(dt.imp$steps[k])) {
        i <- dt.imp$interval[k]
        q <- dt.med[interval == i]
        dt.imp$steps[k] = q$mean
    }
}

# check for NAs
q <- is.na(dt.imp$steps)
print(sum(q))

dt.steps_by_date <- dt.imp[, sum(steps), by=date]
setnames(dt.steps_by_date, "V1", "total_steps")

tbl <- dt.steps_by_date[, list(n = .N,  mean = mean(total_steps, na.rm=TRUE), median = median(total_steps, na.rm=TRUE))]
print(tbl)
print(xtable(tbl), type="html", include.rownames=FALSE)
