final Map<String, dynamic> officeMasterData = {
  "office_id": "hq_phnom_penh_01",
  "office_name": "WorkSmart HQ",
  "group_name": "Mobile Development Unit",

  "geofence": {
    "center": {"lat": 11.572430738457149, "lng": 104.89330484272999},
    "radius_meters": 100,
    "address_label": "Phnom Penh, Cambodia",
  },

  "policy": {
    "check_in_start": "08:00 AM",
    "check_out_end": "05:00 PM",
    "late_buffer_minutes": 15,
    "annual_leave_limit": 18,
    "sick_leave_limit": 5,
  },

  "telegram_config": {
    "bot_username": "@WorkSmart_Attendance_Bot",
    "bot_link": "https://t.me/WorkSmart_Attendance_Bot",
    "qr_code_data": "https://t.me/WorkSmart_Bot?start=office_01",
  },
};
