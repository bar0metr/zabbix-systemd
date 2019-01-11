# Zabbix SYSTEMD

В данном шаблоне используется функционал BASH-скриптов, прикрученных к кастомным UserParameter'ам, и изменения в работе конкретных функций можно производить не перезапуская агенты. 


`ВНИМАНИЕ: название шаблона в zabbix = Template Systemd! Это следует учитывать, так как если уже имеется шаблон с таким названием в Zabbix, импорт приведет к баттхерту и потере оригинального шаблона!`
---

### Установка

`Перед установкой необходимо убедиться, что в Zabbix не присутствуют UserParameter'ы одинаковые по названию с теми, которые используются здесь.`
`Необходимо убедиться в корректных настройках файрвола и SELINUX (чтобы скрипты могли "дёргать systemctl") на стороне сервера с zabbix-агентом`
**На стороне хоста с Агентом**
1) Необходимо включить учет cgroup для мониторинга systemd Zabbix:
```bash
sed -i -e "s/.*DefaultCPUAccounting=.*/DefaultCPUAccounting=yes/g" /etc/systemd/system.conf
sed -i -e "s/.*DefaultMemoryAccounting=.*/DefaultMemoryAccounting=yes/g" /etc/systemd/system.conf
systemctl daemon-reexec
systemctl restart zabbix-agent
```
2) Копируем папку **scripts** в каталог **/etc/zabbix/**
3) Убеждаемся, что у всех скриптов из папки выше права 755.
4) Копируем файл **userparameter_systemd.conf** в каталог **/etc/zabbix/zabbix_agentd.d/**
5) Рестартуем zabbix-agent.
```bash
   systemctl restart zabbix-agent
```

**На стороне сервера мониторинга**
1) Добавляем шаблон.
2) Добавляем хост.
3) Профит

---

### Доступные ключи:
#### Discovery

| **Ключ**                            | **Описание**                                                               |
| ------------------------------- | ---------------------------------------------------------------------- |
| linux.systemd.service.discovery[]    | Обнаружение всех известных системных сервисов (кроме multi instance)   |
| linux.systemd.service.discovery.mi[признак_мультиинстанса(обязательный параметр)=mi] | Обнаружение всех известных multi instance системных сервисов.          |
| linux.systemd.cgroup.cpu[имя_сервиса,разделение_между_ядрами(1 - истина, 0 - ложь)=1]           | Утилизация ЦП systemd сервиса в % (для НЕ-multi instance сервисов)     |
| linux.systemd.cgroup.cpu.mi[короткое_имя_сервиса,разделение_между_ядрами(1 - истина, 0 - ложь)=1,имя_инстанса]        | Утилизация ЦП systemd сервиса в % (ТОЛЬКО для multi instance сервисов) |
| linux.systemd.cgroup.mem[имя_сервиса,метрика_памяти]           | Метрика памяти. Только для не-multi instance сервисов |
| linux.systemd.cgroup.mem.mi[короткое_имя_сервиса,метрика_памяти,имя_инстанса]        | Метрика памяти. Только для multi instance сервисов |
| linux.systemd.unit.is-active[имя_сервиса]       | Проверка сервиса на активность (1 - активен, 0 - неактивен). НЕ-multi instance |
| linux.systemd.unit.is-failed[имя_сервиса]       | Проверка сервиса на статус failed (1 - истина, 0 - ложь). НЕ-multi instance |
| linux.systemd.unit.is-enabled[имя_сервиса]      | Включен ли сервис (1 - истина, 0 - ложь). НЕ-multi instance |
| linux.systemd.unit.is-active.mi[короткое_имя_сервиса,имя_инстанса]    | Проверка сервиса на активность (1 - активен, 0 - неактивен). ТОЛЬКО-multi instance |
| linux.systemd.unit.is-failed.mi[короткое_имя_сервиса,имя_инстанса]    | Проверка сервиса на статус failed (1 - истина, 0 - ложь). ТОЛЬКО-multi instance |
| linux.systemd.unit.is-enabled.mi[короткое_имя_сервиса,имя_инстанса]   | Включен ли сервис (1 - истина, 0 - ложь). ТОЛЬКО-multi instance |

---

### Описание работы ключей
#### linux.systemd.service.discovery

`Только для не-multi instance сервисов!`
> Каких-либо входных параметров не требует

Ключ предназначен для автоматического обнаружения не-мультиинстансных systemd сервисов в системе. Возвращает в Zabbix JSON следующего вида (для примера взят обнаруженный сервис dbus.service):
```bash
{
  "data": [
    {
      "{#SYSTEMD.SERVICE.NAME}": "dbus",
      "{#SYSTEMD.SERVICE.DESCRIPTION}": "D-Bus System Message Bus"
    },
    ...
  ]
}
```
**{#SYSTEMD.SERVICE.NAME}** - имя сервиса (до .service).

**{#SYSTEMD.SERVICE.DESCRIPTION}** - описание (description) найденного сервиса.


#### linux.systemd.service.discovery.mi

`Только для multi instance сервисов!`
> Требует обязательного входного параметра **mi** (multi instance)

Ключ предназначен для автоматического обнаружения **только** мультиинстансных systemd сервисов в системе. Возвращает в Zabbix JSON следующего вида (для примера взят обнаруженный сервис getty@tty1.service):
```bash
{
  "data": [
    {
      "{#SYSTEMD.SERVICE.FULLNAME.MI}": "getty@tty1",
      "{#SYSTEMD.SERVICE.DESCRIPTION.MI}": "Getty on tty1",
      "{#SYSTEMD.SERVICE.INSTANCE.MI}": "tty1",
      "{#SYSTEMD.SERVICE.NAME.MI}": "getty"
    },
    ...
  ]
}
```
**{#SYSTEMD.SERVICE.FULLNAME.MI}** - полное название сервиса, включая имя инстанса (до .service)

**{#SYSTEMD.SERVICE.DESCRIPTION.MI}** - описание (description) найденного сервиса.

**{#SYSTEMD.SERVICE.DESCRIPTION.MI}** - описание (description) найденного сервиса.

**{#SYSTEMD.SERVICE.INSTANCE.MI}** - имя (название) инстанса (то, что после @ и до .service).

**{#SYSTEMD.SERVICE.NAME.MI}** - короткое название сервиса, до инстанса (@).


#### linux.systemd.cgroup.cpu

`Только для не-multi instance сервисов!`
> Требует входные параметры: название сервиса, переключатель деления результата на кол-во онлайн ядер в системе (по-умолчанию=1, включен)

Ключ предназначен для определения нагрузки сервиса на ЦП. По-умолчанию, результат нагрузки делится на кол-во онлайн ядер в системе, благодаря чему видно не нагрузку сервиса на конкретное ядро ЦП, а на все доступные ядра

#### linux.systemd.cgroup.cpu.mi

`Только для multi instance сервисов!`
> Требует входные параметры: короткое название сервиса, переключатель деления результата на кол-во онлайн ядер в системе (по-умолчанию=1, включен), имя инстанса

Ключ предназначен для определения нагрузки сервиса на ЦП. По-умолчанию, результат нагрузки делится на кол-во онлайн ядер в системе, благодаря чему видно не нагрузку сервиса на конкретное ядро ЦП, а на все доступные ядра

#### linux.systemd.cgroup.mem

`Только для не-multi instance сервисов!`
> Требует входные параметры: название сервиса, имя метрики памяти

Ключ предназначен для снятия метрик памяти сервиса. Метрики снимаются из псевдофайла **memory.stat**.
Доступные метрики: 
*cache, rss, mapped_file, pgpgin, pgpgout, swap, pgfault, pgmajfault, inactive_anon, active_anon, inactive_file, active_file, unevictable, hierarchical_memory_limit, hierarchical_memsw_limit, total_cache, total_rss, total_mapped_file, total_pgpgin, total_pgpgout, total_swap, total_pgfault, total_pgmajfault, total_inactive_anon, total_active_anon, total_inactive_file, total_active_file, total_unevictable*.

> Примечание: если у вас есть проблемы с показателями памяти, убедитесь, что подсистема памяти cgroup включена (параметр ядра: *cgroup_enable=memory*).

#### linux.systemd.cgroup.mem.mi

`Только для multi instance сервисов!`
> Требует входные параметры: короткое название сервиса, имя метрики памяти, имя инстанса

Ключ предназначен для снятия метрик памяти сервиса. Метрики снимаются из псевдофайла **memory.stat**.
Доступные метрики: 
*cache, rss, mapped_file, pgpgin, pgpgout, swap, pgfault, pgmajfault, inactive_anon, active_anon, inactive_file, active_file, unevictable, hierarchical_memory_limit, hierarchical_memsw_limit, total_cache, total_rss, total_mapped_file, total_pgpgin, total_pgpgout, total_swap, total_pgfault, total_pgmajfault, total_inactive_anon, total_active_anon, total_inactive_file, total_active_file, total_unevictable*.

> Примечание: если у вас есть проблемы с показателями памяти, убедитесь, что подсистема памяти cgroup включена (параметр ядра: *cgroup_enable=memory*).

#### linux.systemd.unit.is-active

`Только для не-multi instance сервисов!`
> Требует входные параметры: название сервиса

Ключ предназначен для определения того, активен ли (**active**) сервис (active=1, not active = 0)

#### linux.systemd.unit.is-failed

`Только для не-multi instance сервисов!`
> Требует входные параметры: название сервиса

Ключ предназначен для определения состояния **failed** сервиса (failed=1, not failed=0)

#### linux.systemd.unit.is-enabled

`Только для не-multi instance сервисов!`
> Требует входные параметры: название сервиса

Ключ предназначен для определения состояния **enabled** сервиса (включен=1, выключен=0)

#### linux.systemd.unit.is-active.mi

`Только для multi instance сервисов!`
> Требует входные параметры: короткое название сервиса, имя инстанса

Ключ предназначен для определения того, активен ли (**active**) сервис (active=1, not active = 0)

#### linux.systemd.unit.is-failed.mi

`Только для multi instance сервисов!`
> Требует входные параметры: короткое название сервиса, имя инстанса

Ключ предназначен для определения состояния **failed** сервиса  (failed=1, not failed=0)

#### linux.systemd.unit.is-enabled.mi

`Только для multi instance сервисов!`
> Требует входные параметры: короткое название сервиса, имя инстанса

Ключ предназначен для определения состояния **enabled** сервиса (включен=1, выключен=0)
