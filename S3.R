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

dt.steps_by_interval <- dt[, list(mean = mean(steps, na.rm=TRUE)), by=interval]

png("plotB.png", width=768, height=512)
p <- ggplot(dt.steps_by_interval, aes(x=interval, y=mean)) +
	geom_line() +
    labs(title="Mean steps per interval") +
    labs(x="Interval", y="Average steps")
print(p)

dev.off()

# Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?

print(dt.steps_by_interval)
q <- dt.steps_by_interval[order(mean)]
print(q[nrow(q), interval])