module AttendancesHelper
  # 出退勤ボタンの文字列を切替
  def attendance_state(attendance)
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    false
  end

  # 在社時間を計算(勤怠)
  def working_times(start, finish)
    sta_at = Tod::TimeOfDay.parse("#{format('%.2d', start.hour)}:#{format('%.2d', start.min)}")
    fin_at = Tod::TimeOfDay.parse("#{format('%.2d', finish.hour)}:#{format('%.2d', finish.min)}")
    (fin_at - sta_at).strftime('%H:%M')
  end

  # 在社時間を計算(勤怠変更)
  def edit_working_times(start, finish, check)
    sta_at = Tod::TimeOfDay.parse("#{format('%.2d', start.hour)}:#{format('%.2d', start.min)}")
    fin_at = Tod::TimeOfDay.parse("#{format('%.2d', finish.hour)}:#{format('%.2d', finish.min)}")
    spe_time = fin_at - sta_at
    if fin_at == sta_at && check == true
      "#{format('%.2d', spe_time.hour + 24)}:#{format('%.2d', spe_time.min)}"
    else
      spe_time.strftime('%H:%M')
    end
  end

  # 勤怠変更申請の出勤時間と退勤時間を比較検証。(minも考慮しTod::TimeOfDayで時刻にパースする。)
  def compare_verify_edit_apply_time?(attendance_id, start, finish, check)
    attendance = Attendance.find(attendance_id)
    sta_at = if Tod::TimeOfDay.parsable?(start)
               start
             else
               "#{format('%.2d', attendance.edit_day_started_at.hour)}:#{format('%.2d', attendance.edit_day_started_at.min)}"
             end
    fin_at = if Tod::TimeOfDay.parsable?(finish)
               finish
             else
               "#{format('%.2d', attendance.edit_day_finished_at.hour)}:#{format('%.2d', attendance.edit_day_finished_at.min)}"
             end
    case check
    when '0'
      Tod::TimeOfDay.parse(sta_at) > Tod::TimeOfDay.parse(fin_at) || Tod::TimeOfDay.parse(sta_at) == Tod::TimeOfDay.parse(fin_at)
    when '1'
      Tod::TimeOfDay.parse(sta_at) < Tod::TimeOfDay.parse(fin_at)
    end
  end

  # 残業申請の終了予定時間と退勤時間を比較検証。
  def compare_verify_over_apply_time?(attendance_id, over, check)
    attendance = Attendance.find(attendance_id)
    user = User.find_by(id: attendance[:user_id])
    fin_time = if attendance.finished_at.nil?
                 "#{format('%.2d', user.designated_work_end_time.hour)}:#{format('%.2d', user.designated_work_end_time.min)}"
               else
                 attendance.finished_at
               end
    fin_at = if Tod::TimeOfDay.parsable?(fin_time)
               fin_time
             else
               "#{format('%.2d', attendance.finished_at.hour)}:#{format('%.2d', attendance.finished_at.min)}"
             end
    ove_at = if Tod::TimeOfDay.parsable?(over)
               over
             else
               "#{format('%.2d', attendance.over_end_at.hour)}:E#{format('%.2d', attendance.over_end_at.min)}"
             end
    case check
    when '0'
      Tod::TimeOfDay.parse(fin_at) > Tod::TimeOfDay.parse(ove_at) || Tod::TimeOfDay.parse(fin_at) == Tod::TimeOfDay.parse(ove_at)
    when '1'
      Tod::TimeOfDay.parse(fin_at) < Tod::TimeOfDay.parse(ove_at)
    end
  end

  # 累計在社時間を計算。
  def total_working_times(second)
    hour = 0
    second = 0 if second.nil?
    min = second / 60
    if min >= 60
      hour = min / 60
      min = min % 60
    end
    "#{hour}:#{format('%.2d', min)}"
  end

  # 時間外時間を計算
  def over_times(attendance_id)
    attendance = Attendance.find(attendance_id)
    user = User.find(attendance.user_id)
    finish = attendance.edit_day_request_status == '承認' ? attendance.edit_day_finished_at : attendance.finished_at
    finish = user.designated_work_end_time if finish.nil?
    finish = Tod::TimeOfDay.parse("#{format('%.2d', finish.hour)}:#{format('%.2d', finish.min)}")
    over = Tod::TimeOfDay.parse("#{format('%.2d', attendance.over_end_at.hour)}:#{format('%.2d', attendance.over_end_at.min)}")
    ove_time = (over - finish)
    if finish == over && attendance.over_next_day == true
      "#{format('%.2d', ove_time.hour + 24)}:#{format('%.2d', ove_time.min)}"
    else
      ove_time.strftime('%H:%M')
    end
  end
end
