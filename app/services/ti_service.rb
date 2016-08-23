class TiService
  def self.ti
     ironmq = IronMQ::Client.new(token: "axTC7KCHg5MzuKKYRWG8Ht7OKBg", project_id: "53debc89b28d50000900000b", host: "mq-rackspace-ord.iron.io")
     q = ironmq.queue('translator')

     #loop do 
      msg = q.get
      hash = JSON.parse(msg.body, symbolize_names: true)

      #return if hash[:transaction_item][:source_type] != "league"

      #ti = TransactionItem.create!(hash[:transaction_item])
      TransactionItem.create!(hash[:transaction_item])

      #ti.process
    #end
  end
end