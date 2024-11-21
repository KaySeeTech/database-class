// Query 1: Over how many years was the unemployment data collected?
[
  {
    $group: {
      // use _id to find each distinct year
      _id: "$Year"
    }
  },
  {
    $count:
      // Count each year
      "Distinct_Year"
  }
]

// Query 2: How many states were reported on in this dataset?
[
  {
    $group: {
      // Group states by id
      _id: "$State"
    }
  },
  {
    $count:
      // Use $count to unique states
      "Unique_States"
  }
]

// Query 3: What does this query compute?
db.unemployment.find({Rate : {$lt: 1.0}}).count()

// Result 657, shows counties that had unemployment rate lower than 1%

// Query 4: Find all counties with unemployment rate higher than 10%
[
  {
    $project: {
      // project country and rate
      _id: 0,
      County: 1,
      Rate: 1
    }
  },
  {
    $match: {
      // use $match to find rates higher than 10%
      Rate: {
        $gt: 10
      }
    }
  }
]

// Query 5: Calculate the average unemployment rate across all states.
[
  {
    $group: {
      _id: null,
      // use $avg to find average rate between all states
      averageUnemployment: {
        $avg: "$Rate"
      }
    }
  },
  {
    $project: {
      // remove _id
      _id: 0
    }
  }
]

// Query 6: Find all counties with an unemployment rate between 5% and 8%.
[
  {
    $project: {
      // remove _id
      _id: 0,
      County: 1,
      Rate: 1
    }
  },
  {
    $match: {
      // use combo of $gt and $lt to find counties that fit criteria
      // assummption that it is exclusive
      Rate: {
        $gt: 5,
        $lt: 8
      }
    }
  }
]

// Query 7: Find the state with the highest unemployment rate
[
  {
    $group: {
      // group by state and find average rate
      _id: "$State",
      averageUnemployment: {
        $avg: "$Rate"
      }
    }
  },
  {
    $sort: {
      // sort from most to least
      averageUnemployment: -1
    }
  },
  {
    $limit:
      // show only 1 state
      1
  }
]

// Query 8: Count how many counties have an unemployment rate above 5%.
[
  {
    $project: {
      // show county and rate
      _id: 0,
      County: 1,
      Rate: 1
    }
  },
  {
    $match: {
      // find county where rate is greater than 5%
      Rate: {
        $gt: 5
      }
    }
  },
  {
    $count:
      // count the counties
      "Counties"
  }
]

// Query 9: Calculate the average unemployment rate per state by year
[
  {
    $project: {
      // ignore month and _id
      _id: 0,
      Month: 0
    }
  },
  {
    $group: {
      // create id with year and state
      _id: {
        year: "$Year",
        state: "$State"
      },
      // group by average rate
      rate: {
        $avg: "$Rate"
      }
    }
  },
  {
    $project: {
      // show year and state by rate
      _id: 0,
      year: "$_id.year",
      state: "$_id.state",
      rate: 1
    }
  }
]

// Query 10: For each state, calculate the total unemployment rate across all counties (sum of all county rates)
[
  {
    $group: {
      // group by state by rate average
      _id: "$State",
      rate: {
        $sum: "$Rate"
      }
    }
  }
]

// Query 11: The same as Query 10 but for states with data from 2015 onward
[
  {
    $group: {
      // group by state and year by rate average
      _id: {
        state: "$State",
        year: "$Year"
      },
      rate: {
        $avg: "$Rate"
      }
    }
  },
  {
    $match: {
      // find states where year is greater than 2015
      "_id.year": {
        $gte: 2015
      }
    }
  },
  {
    $project: {
      // show year, state, and rate
      _id: 0,
      year: "$_id.year",
      state: "$_id.state",
      rate: 1
    }
  }
]
