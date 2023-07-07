#ifndef EVENTSTATISTICSYSTEM_H
#define EVENTSTATISTICSYSTEM_H


#include <ve_eventsystem.h>
#include <QTimer>

class EventStatisticSystem : public VeinEvent::EventSystem
{
  Q_OBJECT
  Q_PROPERTY(int eventsPerMinute READ eventsPerMinute NOTIFY sigEventsPerMinuteChanged)
  Q_PROPERTY(int eventsPerSecond READ eventsPerSecond NOTIFY sigEventsPerSecondChanged)

public:
  explicit EventStatisticSystem(QObject *t_parent = nullptr);
  virtual ~EventStatisticSystem() override {}
  int eventsPerMinute() const;
  int eventsPerSecond() const;
  static EventStatisticSystem *getStaticInstance();
  static void setStaticInstance(EventStatisticSystem *t_instance);
  void processEvent(QEvent *t_event) override;

signals:
  void sigEventsPerMinuteChanged(int eventsPerMinute);
  void sigEventsPerSecondChanged(int eventsPerSecond);




private slots:
  void updateAverage();

private:
  int m_eventCounter=0;
  int m_averageCounter=0;
  int m_timerCounter=0;
  int m_eventsPerMinute=0;
  int m_eventsPerSecond=0;
  QTimer m_averageTimer;
  static EventStatisticSystem *s_staticInstance;
};

#endif // EVENTSTATISTICSYSTEM_H
