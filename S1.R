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

# set NA to 0
for (k in seq_len(ncol(dt))) {
    set(dt, which(is.na(dt[[k]])), k, 0)
}

dt.steps_by_date <- dt[, sum(steps), by=date]
setnames(dt.steps_by_date, "V1", "total_steps")
print(dt.steps_by_date)

#plotting
png("plotA.png", width=768, height=512)
p <- ggplot(dt.steps_by_date, aes(x = total_steps)) +
       geom_histogram(alpha=0.3, binwidth=1000,
                     col="red",
                     aes(fill=..count..)) +
       scale_fill_gradient("Count", low = "blue", high = "red") +
       labs(title="Histogram of the total steps per day") +
       labs(x="Date", y="Number of steps")
print(p)

dev.off()
