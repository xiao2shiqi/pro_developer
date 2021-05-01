# 定义父类
class Person
    def name
        p "person name"
    end
end

# 定义子类
class Customer < Person
end

customer = Customer.new
p "customer: #{customer}" 
p "customer_class: #{customer.class}"
p "Customer SuperClass: #{Customer.superclass}"
p "have name methods? #{customer.respond_to?(:name)}"