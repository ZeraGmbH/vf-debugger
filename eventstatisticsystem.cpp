#include "eventstatisticsystem.h"

EventStatisticSystem *EventStatisticSystem::s_staticInstance=nullptr;

EventStatisticSystem::EventStatisticSystem(QObject *t_parent) : VeinEvent::EventSystem(t_parent)
{
  connect(&m_averageTimer, &QTimer::timeout, this, &EventStatisticSystem::updateAverage);
  m_averageTimer.setInterval(1000);
  m_averageTimer.setSingleShot(false);
  m_averageTimer.start();
}

int EventStatisticSystem::eventsPerMinute() const
{
  return m_eventsPerMinute;
}

int EventStatisticSystem::eventsPerSecond() const
{
  return m_eventsPerSecond;
}

EventStatisticSystem *EventStatisticSystem::getStaticInstance()
{
  return s_staticInstance;
}

void EventStatisticSystem::setStaticInstance(EventStatisticSystem *t_instance)
{
  if(s_staticInstance==nullptr)
  {
    s_staticInstance = t_instance;
  }
}

void EventStatisticSystem::processEvent(QEvent *t_event)
{
  Q_UNUSED(t_event);
  //events counted include both commandevents and protocolevents
  //so the displayed number should be twice of what the database replay shows with '-t 1000'
  m_eventCounter++;
}

void EventStatisticSystem::updateAverage()
{
  m_timerCounter++;
  m_eventsPerSecond=m_eventCounter;
  emit sigEventsPerSecondChanged(m_eventsPerSecond);
  m_averageCounter+=m_eventCounter;
  m_eventCounter=0;
  //average over the last 4 values
  if (m_timerCounter > 3) {
      m_eventsPerMinute = (m_averageCounter/(m_timerCounter))*60;
      m_averageCounter = 0;
      m_timerCounter = 0;
      emit sigEventsPerMinuteChanged(m_eventsPerMinute);
  }
}
