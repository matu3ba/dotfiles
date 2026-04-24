local has_visits, visits = pcall(require, 'mini.visits')
if not has_visits then
  error 'Please install nvim-mini/mini.visits'
  return
end
visits.setup({})
