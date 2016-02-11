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

      return { ...state, started: false, timer: timer, duration: timer.time };

    default:
      return state;
  }
}
