import dayjs from 'dayjs';

export const formatDate = (date) => {
  return dayjs(date).format('YYYY-MM-DD');
};

export const getCurrentSemester = (date, semestersList) => {
  const targetDate = dayjs(date);
  return semestersList.find(s => 
    targetDate.isAfter(dayjs(s.startDate)) && targetDate.isBefore(dayjs(s.endDate))
  );
};

export default { formatDate, getCurrentSemester };
