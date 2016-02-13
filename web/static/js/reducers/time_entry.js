import Constants  from '../constants';

const initialState = {
  start: '00:00:00',
  stop: null,
  duration: 0,
  started: false,
  timer: null,
  timeEntry: null,
};

export default function reducer(state = initialState, action = {}) {
  switch (action.type) {
    case Constants.TIMER_START:
      return { ...state, started: true, timer: action.timer, timeEntry: action.timeEntry };

    case Constants.TIMER_STOP:
      const { timer } = action;

      return { ...initialState };

    case Constants.TIMER_SET_TIME_ENTRY:
      const { timeEntry } = action;

      return { ...state, timeEntry: timeEntry };
    default:
      return state;
  }
}
