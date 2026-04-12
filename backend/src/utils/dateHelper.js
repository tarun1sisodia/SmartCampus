const dayjs = require('dayjs');

exports.formatDate = (date) => {
  return dayjs(date).format('YYYY-MM-DD');
};

exports.getCurrentSemester = (date, semestersList) => {
  const targetDate = dayjs(date);
  return semestersList.find(s => 
    targetDate.isAfter(dayjs(s.startDate)) && targetDate.isBefore(dayjs(s.endDate))
  );
};
